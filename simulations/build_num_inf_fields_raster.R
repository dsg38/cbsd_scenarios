options(stringsAsFactors = FALSE)
# infRasterDir = "./sim_output/2021_03_17_cross_continental/2021_03_18_batch_0/job0/"
# hostRasterPath = "../inputs/inputs_scenarios/2021_03_17_cross_continental/inputs/L_0_HOSTDENSITY.txt"

infRasterDir = "/rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/cbsd_scenarios/simulations/sim_output/2021_03_21_nigeria_resistant/2021_03_21_batch_1/job0/"
hostRasterPath = "../inputs/inputs_scenarios/2021_03_18_nigeria_region/inputs/L_0_HOSTDENSITY.txt"


# -------------------------------------------------------------------

infRasterPaths = list.files(infRasterDir, pattern="O_0_L_0_INFECTIOUS_.*.000000.tif", full.names = T, recursive = T)

hostRaster = raster::raster(hostRasterPath)

for(infRasterPath in infRasterPaths){
    
    print(infRasterPath)
    
    # Out path
    outPathRaster = gsub('.tif', '_NUMFIELDS.tif', infRasterPath)

    infRaster = raster::raster(infRasterPath)

    outRaster = infRaster * hostRaster * 1000
    
    outRaster[outRaster>0 & outRaster<1] = 1

    raster::writeRaster(outRaster, outPathRaster, overwrite=TRUE)
    
}



