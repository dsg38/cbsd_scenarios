library(tictoc)

args = commandArgs(trailingOnly=TRUE)

constraintKey = as.character(args[[1]])
rasterYear = as.character(args[[2]])
nBatches = as.numeric(args[[3]])
batchIndex = as.character(args[[4]])

# constraintKey = "uga-RWA-BDI-drc_first_east-Pweto-zmb_regions_union-drc_north_central_field"
# constraintKey = "all"

# rasterYear = "2050"
# nBatches = 10
# batchIndex = "1"

# ---------------------

# Read in all pass keys with different constraints
passKeysAll  = rjson::fromJSON(file="../output/cumulative_passKeys.json")

# Extract subset of keys for our target constraints
passKeys = passKeysAll[[constraintKey]]

# Pull out the job names
splitList = stringr::str_split(passKeys, pattern="-")
jobVec = sort(sapply(splitList, dplyr::nth, n=3))

# Split jobVec into batches
jobBatchList = split(jobVec, sort(rep_len(1:nBatches, length(jobVec))))

if(sum(sapply(jobBatchList, length)) != length(jobVec)){
    stop("Batch splitting broken")
}

if(!(as.character(batchIndex) %in% names(jobBatchList))){
    stop("Invalid batchIndex")
}

jobVecBatch = jobBatchList[[as.character(batchIndex)]]

i = 0
tic()
for(thisJob in jobVecBatch){
    
    boolRasterPath = file.path("./output/bool", paste0("inf_rasters_", rasterYear), paste0(thisJob, "-O_0_L_0_INFECTIOUS_", rasterYear, ".000000.tif"))
    
    if(!file.exists(boolRasterPath)){
        print(boolRasterPath)
        stop("Bool raster missing")
    }
        
    print(i)
    
    if(i == 0){
        
        sumRaster = raster::raster(boolRasterPath)
        
    }else{
        
        sumRaster = sumRaster + raster::raster(boolRasterPath)
        
    }
    
    
    i = i + 1
    
}
toc()

# Write out raster
sumRasterBatchOutDir = file.path("./output/sum", constraintKey, paste0("inf_rasters_", rasterYear))
dir.create(sumRasterBatchOutDir, recursive = TRUE, showWarnings = FALSE)

sumRasterBatchOutPath = file.path(sumRasterBatchOutDir, paste0("rasterYear_", rasterYear, "-", "batchIndex_", batchIndex, ".tif"))

raster::writeRaster(sumRaster, sumRasterBatchOutPath, overwrite=TRUE)

