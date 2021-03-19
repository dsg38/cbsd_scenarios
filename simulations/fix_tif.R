topDir = "./sim_output/2021_03_17_cross_continental/2021_03_18_batch_0/"
endYear = 2050

# Get only last ones to avoid sims in prog
lastRasterPaths = list.files(topDir, pattern=paste0("O_0_L_0_INFECTIOUS_", endYear, ".000000.txt"), full.names = T, recursive = T)

fixCount = 0
for(thisLastRasterPath in lastRasterPaths){
        
    thisResultsDir = dirname(thisLastRasterPath)
    
    print(thisResultsDir)
    
    allRasterPaths = list.files(thisResultsDir, pattern="O_0_L_0_INFECTIOUS_.*.000000.txt", full.names = T)
    
    # HACK SO I CAN SPAWN MULTIPLE
    if("O_0_L_0_INFECTIOUS_2004.000000.txt" %in% allRasterPaths){
        
        for(thisRasterPath in allRasterPaths){
            
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
        
    }
    
}
