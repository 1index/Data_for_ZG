#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Thickness inversion from 3D velocity fields.

Core idea:
- Unknown thickness field h(x,y) is solved on a "solvable domain" defined by valid velocity pixels.
- Build a linear operator G so that the discrete relation f * div(h * v_xy) approximates -v_z.
- Add boundary constraint h=0 on boundary ring (optionally exclude toe region).
- Add Laplacian regularization (smoothness): lambda * ||L h||_2
- Solve convex problem with box constraints: 0 <= h <= up using cvxpy.

"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Optional, Tuple, Dict, List

import numpy as np
import rasterio
from rasterio.enums import Resampling
from scipy.ndimage import binary_erosion, binary_dilation, generate_binary_structure
from scipy import sparse
import cvxpy as cp


# ============================================================
# Data structures
# ============================================================

@dataclass
class RasterData:
    """Container for raster array + metadata for writing output GeoTIFF."""
    arr: np.ndarray  # 2D float array
    profile: dict    # rasterio profile


@dataclass
class DomainIndex:
    """
    Index mapping between grid cells and unknown vector indices.

    - cc mask meaning:
        0: not used
        1: internal solvable cell (equations built)
        2: boundary ring cell (unknown exists, but constrained h=0 by default)
    """
    cc: np.ndarray                    # 2D int mask
    hij: np.ndarray                   # (N,2) list of (row, col) for cc!=0
    ij_to_k: Dict[Tuple[int, int], int]  # map (row,col) -> k index in [0..N-1]
    internal_ij: np.ndarray           # list of (row,col) where cc==1
    boundary_ij: np.ndarray           # list of (row,col) where cc==2


# ============================================================
# I/O helpers
# ============================================================

def read_geotiff(path: str | Path) -> RasterData:
    """Read a GeoTIFF as float64 and keep metadata for output."""
    path = Path(path)
    with rasterio.open(path) as src:
        arr = src.read(1).astype(np.float64)
        profile = src.profile.copy()
    return RasterData(arr=arr, profile=profile)


def write_geotiff(path: str | Path, arr: np.ndarray, ref_profile: dict) -> None:
    """Write a single-band GeoTIFF using a reference raster profile."""
    path = Path(path)
    profile = ref_profile.copy()
    profile.update(
        dtype=rasterio.float32,
        count=1,
        compress="deflate",
        predictor=2,
        tiled=True,
    )

    path.parent.mkdir(parents=True, exist_ok=True)
    with rasterio.open(path, "w", **profile) as dst:
        dst.write(arr.astype(np.float32), 1)


# ============================================================
# Preprocessing
# ============================================================

def sanitize_velocity(v: np.ndarray, invalid_threshold: float = 1e6) -> np.ndarray:
    """
    - abs()
    - values > invalid_threshold => 0
    - NaNs => 0
    """
    v = np.abs(v.astype(np.float64))
    v[v > invalid_threshold] = 0.0
    v[np.isnan(v)] = 0.0
    return v


# ============================================================
# Domain construction (cc mask)
# ============================================================

def build_cc_mask(vx: np.ndarray) -> np.ndarray:
    """
    Build cc mask:
    - cc=1 if vx(i,j) and its 4-neighbors are non-zero (center difference solvable)
    - then define boundary ring cc=2 surrounding cc=1 region
    """
    # 1. Mark non-zero velocity pixels.
    is_nonzero = (vx != 0)

    # 2. Build the 4-neighbor connectivity structure.
    # [[0, 1, 0],
    #  [1, 1, 1],
    #  [0, 1, 0]]
    struct = generate_binary_structure(2, 1)

    # 3. Internal solvable cells (cc=1) must keep their 4-neighbors valid.
    # binary_erosion retains pixels whose center and 4-neighbors are all True.
    cc_ones = binary_erosion(is_nonzero, structure=struct, border_value=0)

    # Remove the outer raster border, matching the finite-difference stencil.
    cc_ones[0, :] = 0;
    cc_ones[-1, :] = 0
    cc_ones[:, 0] = 0;
    cc_ones[:, -1] = 0

    # 4. Boundary ring cells (cc=2) are cells adjacent to the internal domain.
    # Dilate the internal domain to include one surrounding ring.
    cc_dilated = binary_dilation(cc_ones, structure=struct)

    # Boundary ring = dilated domain - internal domain.
    cc_twos = cc_dilated & (~cc_ones)

    # 5. Assemble the integer domain mask.
    cc = np.zeros_like(vx, dtype=np.int8)
    cc[cc_ones] = 1
    cc[cc_twos] = 2  # Boundary cells become unknowns but are constrained separately.

    return cc


def build_domain_index(cc: np.ndarray) -> DomainIndex:
    """Create hij list and mapping dict for cc!=0 cells."""
    hij_list: List[Tuple[int, int]] = []
    ij_to_k: Dict[Tuple[int, int], int] = {}

    nrows, ncols = cc.shape
    for i in range(nrows):
        for j in range(ncols):
            if cc[i, j] != 0:
                k = len(hij_list)
                hij_list.append((i, j))
                ij_to_k[(i, j)] = k

    hij = np.array(hij_list, dtype=np.int32)
    internal_ij = np.argwhere(cc == 1).astype(np.int32)
    boundary_ij = np.argwhere(cc == 2).astype(np.int32)

    return DomainIndex(
        cc=cc,
        hij=hij,
        ij_to_k=ij_to_k,
        internal_ij=internal_ij,
        boundary_ij=boundary_ij,
    )


def apply_toe_boundary_exclusion(
    boundary_ij: np.ndarray,
    toe_window: Optional[Tuple[int, int, int, int]],
) -> np.ndarray:
    """
    Optional: exclude a toe boundary region from being forced to zero thickness.
    - If a <= row <= b and c <= col <= d, then remove from boundary constraints.
    """
    if toe_window is None:
        return boundary_ij

    a, b, c, d = toe_window
    keep = []
    for (r, col) in boundary_ij:
        if (a <= r <= b) and (c <= col <= d):
            continue
        keep.append((r, col))
    return np.array(keep, dtype=np.int32) if keep else np.zeros((0, 2), dtype=np.int32)


# ============================================================
# Matrix assembly
# ============================================================

def build_rhs_z(vz: np.ndarray, cc: np.ndarray, dx: float) -> np.ndarray:
    """
    Here we create z for INTERNAL cells (cc==1), consistent with G's rows.
    """
    vz2 = vz.copy()
    vz2[cc == 0] = 0.0

    internal = np.argwhere(cc == 1)
    vzc = vz2[internal[:, 0], internal[:, 1]]
    # internal vz should already be nonzero, but keep same logic
    vzc = vzc[vzc != 0]
    z = (-2.0 * dx * vzc).astype(np.float64)
    return z


def build_G_matrix(
    vx: np.ndarray,
    vy: np.ndarray,
    domain: DomainIndex,
    f: float,
) -> sparse.csr_matrix:
    """
    Build G matrix (rows = number of internal cells, cols = number of unknowns).
    """
    internal_ij = domain.internal_ij
    n_eq = internal_ij.shape[0]
    n_var = domain.hij.shape[0]

    rows: List[int] = []
    cols: List[int] = []
    data: List[float] = []

    for k, (i, j) in enumerate(internal_ij):
        ind = domain.ij_to_k[(i, j)]
        inds = domain.ij_to_k.get((i - 1, j))
        indx = domain.ij_to_k.get((i + 1, j))
        indz = domain.ij_to_k.get((i, j - 1))
        indy = domain.ij_to_k.get((i, j + 1))

        # Safety: these should exist because cc==1 implies neighbors in solvable set or boundary ring
        if None in (inds, indx, indz, indy):
            # If mapping missing (rare edge-case), skip this equation
            # but keep matrix shape by putting a tiny no-op; better: raise error.
            raise RuntimeError(f"Neighbor index missing at internal cell {(i, j)}")

        # Center coefficient
        c0 = (vx[i + 1, j] - vx[i - 1, j] + vy[i, j + 1] - vy[i, j - 1])

        # Assemble sparse row
        rows.extend([k, k, k, k, k])
        cols.extend([ind, inds, indx, indz, indy])
        data.extend([c0, -vx[i, j], vx[i, j], -vy[i, j], vy[i, j]])

    G = sparse.coo_matrix((np.array(data) * f, (rows, cols)), shape=(n_eq, n_var)).tocsr()
    return G


def build_boundary_constraint_matrix(
    domain: DomainIndex,
    boundary_ij_used: np.ndarray,
) -> sparse.csr_matrix:
    """
    Build G2 matrix such that G2 * h = 0 enforces h=0 at boundary pixels.

    Each boundary pixel corresponds to one variable index -> one row with a single 1.
    """
    n_var = domain.hij.shape[0]
    n_b = boundary_ij_used.shape[0]

    if n_b == 0:
        return sparse.csr_matrix((0, n_var), dtype=np.float64)

    rows = np.arange(n_b, dtype=np.int32)
    cols = np.array([domain.ij_to_k[(int(r), int(c))] for r, c in boundary_ij_used], dtype=np.int32)
    data = np.ones(n_b, dtype=np.float64)

    G2 = sparse.coo_matrix((data, (rows, cols)), shape=(n_b, n_var)).tocsr()
    return G2


def build_laplacian_matrix(domain: DomainIndex) -> sparse.csr_matrix:
    """
    Build discrete Laplacian L on the variable graph (4-neighborhood).

    This yields Lh = sum(neighbor h) - k*h.
    """
    hij = domain.hij
    n_var = hij.shape[0]

    rows: List[int] = []
    cols: List[int] = []
    data: List[float] = []

    for i in range(n_var):
        r, c = int(hij[i, 0]), int(hij[i, 1])
        neighbors = [(r - 1, c), (r + 1, c), (r, c - 1), (r, c + 1)]
        k = 0

        for nr, nc in neighbors:
            j = domain.ij_to_k.get((nr, nc))
            if j is not None:
                rows.append(i)
                cols.append(j)
                data.append(1.0)
                k += 1

        # center
        rows.append(i)
        cols.append(i)
        data.append(-float(k))

    L = sparse.coo_matrix((data, (rows, cols)), shape=(n_var, n_var)).tocsr()
    return L


# ============================================================
# Optimization (CVX -> cvxpy)
# ============================================================

def solve_thickness_cvxpy(
    G3: sparse.csr_matrix,
    z1: np.ndarray,
    L: sparse.csr_matrix,
    lamda: float,
    up: float,
    solver: str = "OSQP",
) -> np.ndarray:
    """
    Solve:
      minimize ||G3 h - z1||_2^2 + ||lamda * L h||_2^2
      subject to 0 <= h <= up


    In cvxpy:
      Minimize( sum_squares(G3@h - z1) + sum_squares(lamda*(L@h)) )
    """
    n_var = G3.shape[1]
    h = cp.Variable(n_var, nonneg=True)

    # Use sparse matrices directly
    obj = cp.sum_squares(G3 @ h - z1) + cp.sum_squares(lamda * (L @ h))
    constraints = [h >= 0, h <= up]

    prob = cp.Problem(cp.Minimize(obj), constraints)

    # Choose a solver; OSQP is good for QP, SCS is more general.
    if solver.upper() == "OSQP":
        prob.solve(solver=cp.OSQP, verbose=False)
    elif solver.upper() == "SCS":
        prob.solve(solver=cp.SCS, verbose=False)
    else:
        # Let cvxpy choose if unknown
        prob.solve(verbose=False)

    if h.value is None:
        raise RuntimeError(f"Optimization failed. Status: {prob.status}")

    return np.array(h.value, dtype=np.float64).reshape(-1)


# ============================================================
# Main pipeline
# ============================================================

def thickness_cal_py(
    ve_tif: str | Path,
    vn_tif: str | Path,
    vu_tif: str | Path,
    dx: float,
    f: float,
    lamda: float = 0.1,
    up: float = 120.0,
    toe_window: Optional[Tuple[int, int, int, int]] = None,
    out_tif: str | Path = "thickness_inverted.tif",
    solver: str = "OSQP",
) -> np.ndarray:
    """
    Python equivalent of:
      thickness_cal(ve, vn, vu, dx, f, lamda, up, varargin...)

    Parameters
    ----------
    ve_tif, vn_tif, vu_tif : str/Path
        East, North, Up velocity GeoTIFF paths.
    dx : float
        Grid resolution (same unit as raster spacing).
    f : float
        Rheological/scale parameter.
    lamda : float
        Regularization coefficient, recommend ~0.1.
    up : float
        Upper bound constraint for thickness.
    toe_window : (row_min, row_max, col_min, col_max) or None
        If given, boundary cells within this window are NOT forced to h=0.
    out_tif : output GeoTIFF path
    solver : "OSQP" or "SCS"
    """
    ve = read_geotiff(ve_tif)
    vn = read_geotiff(vn_tif)
    vu = read_geotiff(vu_tif)

    vx = sanitize_velocity(ve.arr)
    vy = sanitize_velocity(vn.arr)
    vz = sanitize_velocity(vu.arr)

    # 1) Build solvable domain mask cc
    cc = build_cc_mask(vx)

    # 2)  vz(cc==0)=0
    vz2 = vz.copy()
    vz2[cc == 0] = 0.0

    # 3) Domain index mapping
    domain = build_domain_index(cc)

    # 4) Build RHS z for internal equations
    # IMPORTANT: We must keep the same ordering as internal_ij
    internal_ij = domain.internal_ij
    vzc = vz2[internal_ij[:, 0], internal_ij[:, 1]].astype(np.float64)
    # Removes zeros; but internal cells should be valid. We'll keep all internal eqs.
    z = (-2.0 * dx * vzc)

    # 5) Build matrices: G, boundary constraints G2, combine to G3
    G = build_G_matrix(vx, vy, domain, f=f)

    boundary_used = apply_toe_boundary_exclusion(domain.boundary_ij, toe_window)
    G2 = build_boundary_constraint_matrix(domain, boundary_used)

    # Stack equations:
    G3 = sparse.vstack([G, G2], format="csr")
    z1 = np.concatenate([z, np.zeros(G2.shape[0], dtype=np.float64)], axis=0)

    # 6) Regularization matrix L (Laplacian)
    L = build_laplacian_matrix(domain)

    # 7) Solve convex optimization
    h_vec = solve_thickness_cvxpy(G3, z1, L, lamda=lamda, up=up, solver=solver)

    # 8) Fill back to raster
    hh = np.zeros_like(vx, dtype=np.float64)
    for k, (r, c) in enumerate(domain.hij):
        hh[int(r), int(c)] = h_vec[k]

    # Sets NaN to 0 before writing; ours already has zeros elsewhere
    hh[np.isnan(hh)] = 0.0

    # 9) Write GeoTIFF
    write_geotiff(out_tif, hh, ve.profile)
    print("Thickness inversion result written to:", out_tif)

    return hh


# ============================================================
# CLI usage example (optional)
# ============================================================

if __name__ == "__main__":
    if __name__ == "__main__":
        ve_path = r""
        vn_path = r""
        vu_path = r""
        out_path = r""

        thickness_cal_py(
            ve_tif=ve_path,
            vn_tif=vn_path,
            vu_tif=vu_path,
            dx=30,      #Grid resolution (m)
            f=0.9,      #Rheological coefficient
            lamda=0.1,  #Regularization coefficient
            up=120,     #Maximum sole thickness constraint
            toe_window=None,
            out_tif=out_path,
            solver="OSQP",    #Solver
        )

