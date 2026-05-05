# Data_for_ZG
Supporting code and data for the ZG landslide remote-sensing analysis
====================================================================

This repository contains three folders used to support the analyses reported in the manuscript `Landslide Thickness Inversion and Failure Process Simulation Based on InSAR-Derived 3D Deformation: A Case Study of the Gushui Hydropower Station Reservoir Area`.

1. `3D Deformation Inversion`
   - Contains `Cal_3D_ENU_SPF.m`, a MATLAB script for inverting three-dimensional East-North-Up (ENU) deformation components from multi-track InSAR line-of-sight observations.
   - The script samples incidence angle, azimuth, slope, and aspect rasters, matches neighboring observations among the P26, P128, and P62 tracks, applies a slope-parallel flow constraint, and writes `result_U_SPF.txt`, `result_E_SPF.txt`, and `result_N_SPF.txt`.

2. `Landslide Thickness Inversion`
   - Contains `Thickness_inversion_landslide.py`, a Python implementation for estimating landslide thickness from 3D velocity fields.
   - The script builds a solvable raster domain, assembles sparse finite-difference and boundary-constraint matrices, applies Laplacian regularization, solves a constrained convex optimization problem with `cvxpy`, and exports the inverted thickness field as a GeoTIFF.

3. `r.avaflow numerical simulation`
   - Contains `ZG_rs.avaflow.start.sh` and the GeoTIFF inputs in the `DATA` subfolder.
   - The shell script imports DEM and release-thickness rasters into GRASS GIS, prepares landslide and subsoil layers, and launches r.avaflow simulations for release-thickness scenarios.

Notes
-----

- File paths for some input data are intentionally left blank in the scripts and should be filled according to the local data location before running.
