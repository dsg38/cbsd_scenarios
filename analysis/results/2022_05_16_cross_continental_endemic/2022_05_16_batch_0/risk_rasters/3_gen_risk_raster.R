args = commandArgs(trailingOnly=TRUE)

rasterYear = args[[1]]
# rasterYear = 2050

sumRasterDir = file.path("./output/sum/", paste0("inf_rasters_", rasterYear))
outPath = file.path("./output/risk/", paste0("risk_", rasterYear, ".tif"))

dir.create(dirname(outPath), recursive = TRUE, showWarnings = FALSE)

# -------------------------------------------

# Read in all pass keys with different constraints
passKeysAll  = rjson::fromJSON(file="../output/cumulative_passKeys.json")

# Extract subset of keys for our target constraints
constraintKey = "uga-RWA-BDI-drc_first_east-Pweto-zmb_regions_union-drc_north_central_field"
passKeys = passKeysAll[[constraintKey]]

numJobs = length(passKeys)

# Read in batch sum rasters
allFiles = list.files(sumRasterDir, full.names=TRUE)

sumRasterPaths = allFiles[!stringr::str_detect(allFiles, ".xml")]

i = 0
for(thisRasterPath in sumRasterPaths){
    
    print(i)
    
    if(i == 0){
        bigRaster = raster::raster(thisRasterPath)
    }else{
        bigRaster = bigRaster + raster::raster(thisRasterPath)
    }
    
    i = i + 1
    
}

riskRaster = bigRaster / numJobs

raster::writeRaster(riskRaster, outPath, overwrite=TRUE)
