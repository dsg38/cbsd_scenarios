args = commandArgs(trailingOnly=TRUE)

configPath = args[[1]]
aggOnlyFinishedBool = as.logical(as.numeric(args[[2]]))

# configPath = "../results/2022_03_15_cross_continental_endemic/2022_03_20_batch_0/config_inf_polys.json"
# aggOnlyFinishedBool = 0

config = rjson::fromJSON(file=configPath)

batchPath = here::here(config[["batchPath"]])

batchName = basename(batchPath)
scenarioName = basename(dirname(batchPath))
outputsDir = here::here("analysis/results", scenarioName, batchName, "output")

outPath = here::here(outputsDir, "raster_poly_stats_agg.rds")
outPathMinimal = here::here(outputsDir, "raster_poly_stats_agg_minimal.rds")


# --------------------------------------------------------------------------

# Only agg finished
statsDfPathsAll = list.files(batchPath, pattern="raster_poly_stats.rds", full.names = T, recursive = T)

if(aggOnlyFinishedBool){

    progDfPath = here::here(batchPath, "progress.csv")

    progDf = read.csv(progDfPath)

    doneDf = progDf[progDf$dpcLastSimTime==progDf$simEndTime,]

    statsDfPaths = c()
    for(thisPath in statsDfPathsAll){
        splitPath = strsplit(thisPath, "*/")[[1]]
        
        job = dplyr::nth(splitPath, -4)
        
        if(job%in%doneDf$jobName){
            statsDfPaths = c(statsDfPaths, thisPath)
        }
        
    }

}else{


    statsDfPaths = statsDfPathsAll

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
