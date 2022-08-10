args = commandArgs(trailingOnly=TRUE)

configPath = args[[1]]
saveSubsetFinishedBool = as.logical(as.numeric(args[[2]]))

saveSubsetPresentDayBool = TRUE
if(length(args) == 3){
    saveSubsetPresentDayBool = as.logical(as.numeric(args[[3]]))
}


# configPath = "../results/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/config/config_paths.json"
# aggOnlyFinishedBool = 0

config = rjson::fromJSON(file=configPath)

batchPath = here::here(config[["batchPath"]])

batchName = basename(batchPath)
scenarioName = basename(dirname(batchPath))
outputsDir = here::here("analysis/results", scenarioName, batchName, "output")

dir.create(outputsDir, showWarnings = FALSE, recursive = TRUE)

# ----------------------------------------

# Function that rbinds and saves a list of the files
aggStatsDf = function(statsDfPaths, mergedDfOutPath){

    dfList = list()
    count = 0
    for(statsDfPath in statsDfPaths){

        print(count)
        
        dfList[[statsDfPath]] = readRDS(statsDfPath)

        count = count + 1
    }

    mergedDf = dplyr::bind_rows(dfList)
    print(mergedDfOutPath)
    saveRDS(mergedDf, mergedDfOutPath)

    return(mergedDf)

}

genMinimalDf = function(mergedDf, outPathMinimal){

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
        "scenario",
        "simKey"
    )

    outDfMinimal = mergedDf[,keepCols]
    print(outPathMinimal)
    saveRDS(outDfMinimal, outPathMinimal)

}

# Agg all
mergedDfOutPath = here::here(outputsDir, "raster_poly_stats_agg.rds")
outPathMinimal = here::here(outputsDir, "raster_poly_stats_agg_minimal.rds")

statsDfPathsAll = list.files(batchPath, pattern="raster_poly_stats.rds", full.names = T, recursive = T)

mergedDf = aggStatsDf(
    statsDfPaths=statsDfPathsAll,
    mergedDfOutPath=mergedDfOutPath
)

# Save minimal version of all
genMinimalDf(
    mergedDf=mergedDf,
    outPathMinimal=outPathMinimal
)


if(saveSubsetFinishedBool){
    
    # Extract subset that have finished (done) - use simKey
    mergedDfDoneOutPath = here::here(outputsDir, "raster_poly_stats_agg_DONE.rds")
    outPathDoneMinimal = here::here(outputsDir, "raster_poly_stats_agg_minimal_DONE.rds")

    progDfPath = here::here(batchPath, "progress.csv")

    if(!file.exists(progDfPath)){
        stop("progDf missing")
    }

    progDf = read.csv(progDfPath)

    doneDf = progDf[progDf$dpcLastSimTime==progDf$simEndTime & progDf$dpcLastSimTime == progDf$maxRasterYearTif,]

    doneSimKeys = paste(doneDf$scenarioName, doneDf$batchName, doneDf$jobName, "0", sep="-")

    mergedDfDone = mergedDf[mergedDf$simKey %in% doneSimKeys,]

    saveRDS(mergedDfDone, mergedDfDoneOutPath)

    # Save minimal version of done
    genMinimalDf(
        mergedDf=mergedDfDone,
        outPathMinimal=outPathDoneMinimal
    )

    # ---------------------------------------------

    if(saveSubsetPresentDayBool){
        # Extract subset that made it to 2018 sim time (i.e. last major real-world observation)
        mergedDfPresentDayOutPath = here::here(outputsDir, "raster_poly_stats_agg_PRESENTDAY.rds")
        outPathPresentDayMinimal = here::here(outputsDir, "raster_poly_stats_agg_minimal_PRESENTDAY.rds")

        presentDayDoneDf = progDf[progDf$maxRasterYearTif >= 2018,]

        presentDaySimKeys = paste(presentDayDoneDf$scenarioName, presentDayDoneDf$batchName, presentDayDoneDf$jobName, "0", sep="-")

        mergedDfPresentDay = mergedDf[mergedDf$simKey %in% presentDaySimKeys,]

        saveRDS(mergedDfPresentDay, mergedDfPresentDayOutPath)

        # Save minimal version of done
        genMinimalDf(
            mergedDf=mergedDfPresentDay,
            outPathMinimal=outPathPresentDayMinimal
        )

    }


}
