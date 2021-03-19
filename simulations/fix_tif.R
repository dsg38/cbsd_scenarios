topDir = "./sim_output/2021_03_17_cross_continental/"

# Get only last ones to avoid sims in prog
txtRasterPaths = list.files(topDir, pattern="O_0_L_0_INFECTIOUS_.*.000000.txt", full.names = T, recursive = T)

fixCount = 0
while(length(txtRasterPaths) > 0){
    
    # Pick one
    thisRasterPath = sample(txtRasterPaths, 1)
    
    # Check file old enough
    rasterCreated = file.info(thisRasterPath)$ctime
    timeDiff = Sys.time() - rasterCreated
    numSecs = as.numeric(timeDiff, units = "secs")
    
    if(numSecs > 1000){
        
        print(thisRasterPath)
        
        # Read raster
        thisRaster = raster::raster(thisRasterPath)
        
        outRasterPath = gsub(".txt", ".tif", thisRasterPath)
        
        # Write out as tif
        raster::writeRaster(thisRaster, outRasterPath, overwrite=TRUE)
        
        # Delete old raster
        file.remove(thisRasterPath)
        
        fixCount = fixCount + 1
        print(fixCount)
        
    }
    
    # Regen list of rasters
    txtRasterPaths = list.files(topDir, pattern="O_0_L_0_INFECTIOUS_.*.000000.txt", full.names = T, recursive = T)
    
    print("NUM LEFT TO FIX:")
    print(length(txtRasterPaths))
    
}
