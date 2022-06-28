library(tictoc)

args = commandArgs(trailingOnly=TRUE)

rasterYear = args[[1]]
batchIndex = args[[2]]
# rasterYear = 2050
# batchIndex = 0

# ----------------------
# Set up dir paths
topDir = file.path("./output/raw", paste0("inf_rasters_", rasterYear))
outDir = file.path("./output/bool", basename(topDir))

dir.create(outDir, showWarnings = FALSE, recursive = TRUE)

# Logic to break processing into batches of n size
numJobsPerBatch = 100
numJobsMax = 9999

jobIndexVec = seq(0, numJobsMax)
jobBatchBreakpoints = seq(0, numJobsMax, numJobsPerBatch)

jobIndexBatches = list()
batchCount = 0
for(i in jobBatchBreakpoints){
    
    thisBatch = c()

    for(j in jobIndexVec){
        
        if(j >= i & j < i+numJobsPerBatch){
            thisBatch = c(thisBatch, j)
        }
        
    }
    
    jobIndexBatches[[as.character(batchCount)]] = thisBatch
    
    batchCount = batchCount + 1

}

# Pull out subset of jobs to be processed here
jobIndexVecSubset  = jobIndexBatches[[as.character(batchIndex)]]

# --------------------------
# Process jobs
tic()
for(iJob in jobIndexVecSubset){

    thisRasterPath = file.path(topDir, paste0("job", iJob, "-O_0_L_0_INFECTIOUS_", rasterYear, ".000000.tif"))

    if(file.exists(thisRasterPath)){
        
        print(iJob)
        print(thisRasterPath)
        
        boolRaster = raster::raster(thisRasterPath) > 0

        outPath = file.path(outDir, basename(thisRasterPath))

        raster::writeRaster(boolRaster, outPath, overwrite=TRUE)

    }

}
toc()
