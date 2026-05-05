# Launching r.avaflow simulations for the Koefels rock slide

r.in.gdal -o --overwrite input=DATA/DEM_COP30_project.tif output=ZG_elev
r.in.gdal -o --overwrite input=DATA/ZG1_II_big_I_050_project.tif output=h_ZG1_I_II_050_project
r.in.gdal -o --overwrite input=DATA/ZG1_II_big_I_075_project.tif output=h_ZG1_I_II_075_project
r.in.gdal -o --overwrite input=DATA/ZG1_II_big_I_100_project.tif output=h_ZG1_I_II_100_project



g.region -s rast=ZG_elev


r.mapcalc --overwrite "ZG_landslide1 = if(isnull(h_ZG1_I_II_050_project), 0, h_ZG1_I_II_050_project)"
r.mapcalc --overwrite "ZG_landslide2 = if(isnull(h_ZG1_I_II_075_project), 0, h_ZG1_I_II_075_project)"
r.mapcalc --overwrite "ZG_landslide3 = if(isnull(h_ZG1_I_II_100_project), 0, h_ZG1_I_II_100_project)"

r.mapcalc --overwrite "ZG_Subsoil1 = if(ZG_landslide1>0,(ZG_landslide1* 1.8 / 127) + 0.2,0)"
r.mapcalc --overwrite "ZG_Subsoil2 = if(ZG_landslide2>0,(ZG_landslide2* 1.8 / 127) + 0.2,0)"
r.mapcalc --overwrite "ZG_Subsoil3 = if(ZG_landslide3>0,(ZG_landslide3* 1.8 / 127) + 0.2,0)"


profile1="17475621.15,3164194.35,17476731.30,3164966.28"
profile2="17475478.49,3164691.79,17476553.98,3165260.82"
hydrocoords="17476511.14,3164984.01,2000,220"
time="5,300"

r.mapcalc --overwrite "ZG_DEM = ZG_elev-ZG_landslide-ZG_Subsoil"
r.mapcalc --overwrite "ZG_DEM1 = ZG_elev-ZG_landslide-ZG_Subsoil"
r.mapcalc --overwrite "ZG_DEM2 = ZG_elev-ZG_landslide-ZG_Subsoil"
r.mapcalc --overwrite "ZG_DEM3 = ZG_elev-ZG_landslide-ZG_Subsoil"


r.avaflow.40G prefix=zg_exp1_rs_fin_050g cellsize=30 phases=3 clayers=1 cdispersion=0 csurface=0 elevation=ZG_DEM1 time="$time" friction=26.5,32,0,14.8,17,0,0,0,0 hrelease1=ZG_Subsoil1 hrelease2=ZG_landslide1 cohesion=0,0,0 density=2090,2192,0 centrainment=1 cstopping=0 entrainment=-7.5,0.01 deformation=0.9,0.7,1.0 profile="$profile1" hydrocoords="$hydrocoords" visualization=1,1.0,5.0,5.0,1,1000,20,0,3000,50,0.50,0.50,0.50,0.2,1.0,None,None,None 

r.avaflow.40G prefix=zg_exp1_rs_fin_075g cellsize=30 phases=3 clayers=1 cdispersion=0 csurface=0 elevation=ZG_DEM2 time="$time" friction=26.5,32,0,14.8,17,0,0,0,0 hrelease1=ZG_Subsoil2 hrelease2=ZG_landslide2 cohesion=0,0,0 density=2090,2192,0 centrainment=1 cstopping=0 entrainment=-7.5,0.01 deformation=0.9,0.7,1.0 profile="$profile1" hydrocoords="$hydrocoords" visualization=1,1.0,5.0,5.0,1,1000,20,0,3000,50,0.50,0.50,0.50,0.2,1.0,None,None,None 

r.avaflow.40G prefix=zg_exp1_rs_fin_100g cellsize=30 phases=3 clayers=1 cdispersion=0 csurface=0 elevation=ZG_DEM3 time="$time" friction=26.5,32,0,14.8,17,0,0,0,0 hrelease1=ZG_Subsoil3 hrelease2=ZG_landslide3 cohesion=0,0,0 density=2090,2192,0 centrainment=1 cstopping=0 entrainment=-7.5,0.01 deformation=0.9,0.7,1.0 profile="$profile1" hydrocoords="$hydrocoords" visualization=1,1.0,5.0,5.0,1,1000,20,0,3000,50,0.50,0.50,0.50,0.2,1.0,None,None,None 
g.region -d
