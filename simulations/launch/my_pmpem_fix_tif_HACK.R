options(stringsAsFactors = FALSE)
args = commandArgs(trailingOnly = TRUE)

print("R: TIF CONVERTER RUNNING")

jobNum = args[[1]]

jobDir = file.path("/rds/project/rds-GzjXVr9dEIE/epidem-userspaces/dsg38/cbsd_scenarios/simulations/sim_output/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/", paste0("job", jobNum))

# ----------------------------------------------------------

txtRasterPaths = normalizePath(list.files(jobDir, pattern="O_.*_L_0_.*_.*.txt", full.names = T, recursive = T))
tifRasterPaths = normalizePath(list.files(jobDir, pattern="O_.*_L_0_.*_.*.tif", full.names = T, recursive = T))

print("R: NUM TXT RASTERS:")
print(length(txtRasterPaths))

print("R: NUM TIF RASTERS:")
print(length(tifRasterPaths))

# print("R: LIST OF FILES TO FIX:")
# print(txtRasterPaths)

for(thisTxtRasterPath in txtRasterPaths){
    
    print(thisTxtRasterPath)
    
    # Read raster
    thisRaster = raster::raster(thisTxtRasterPath)
    
    # Build out path
    outPathRaster = gsub(".txt", ".tif", thisTxtRasterPath)
    
    # Write out tif
    raster::writeRaster(thisRaster, outPathRaster, overwrite=TRUE)
    
    # Remove txt raster
    file.remove(thisTxtRasterPath)
    
}

print("DONE")
