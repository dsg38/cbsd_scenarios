options(stringsAsFactors = FALSE)
args = commandArgs(trailingOnly = TRUE)

print("R: TIF CONVERTER RUNNING")

jobDir = args[[1]]

# ----------------------------------------------------------

txtRasterPaths = normalizePath(list.files(jobDir, pattern="O_.*_L_0_.*_.*.txt", full.names = T, recursive = T))

print("R: LIST OF FILES TO FIX:")
print(txtRasterPaths)

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
