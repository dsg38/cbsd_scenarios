args = commandArgs(trailingOnly=TRUE)

configPath = args[[1]]
# configPath = "./2021_03_26_cross_continental/config_poly.json"

config = rjson::fromJSON(file=configPath)

batchPath = here::here(config[["batchPath"]])
outPath = here::here(batchPath, "raster_poly_stats_agg.rds")
outPathMinimal = here::here(batchPath, "raster_poly_stats_agg_minimal.rds")

progDfPath = here::here(batchPath, "progress.csv")

# --------------------------------------------------------------------------

# Only agg finished
progDf = read.csv(progDfPath)

doneDf = progDf[progDf$dpcLastSimTime==progDf$simEndTime,]

statsDfPathsAll = list.files(batchPath, pattern="raster_poly_stats.rds", full.names = T, recursive = T)

statsDfPaths = c()
for(thisPath in statsDfPathsAll){
    splitPath = strsplit(thisPath, "*/")[[1]]
    
    job = dplyr::nth(splitPath, -4)
    
    if(job%in%doneDf$jobName){
        statsDfPaths = c(statsDfPaths, thisPath)
    }
    
}

# --------------------------------


dfList = list()
count = 0
for(statsDfPath in statsDfPaths){

    print(count)
    
    dfList[[statsDfPath]] = readRDS(statsDfPath)

    count = count + 1
}

outDf = dplyr::bind_rows(dfList)
print(outPath)
saveRDS(outDf, outPath)

# Save minimal
keepCols = c(
    "POLY_ID",
    "raster_num_fields",
    "raster_num_cells_populated",
    "raster_prop_fields",
    "raster_year",
    "raster_type",
    "job",
    "batch",
    "scenario"
)

outDfMinimal = outDf[,keepCols]
print(outPathMinimal)
saveRDS(outDfMinimal, outPathMinimal)
