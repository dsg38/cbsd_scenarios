box::use(../utils/sa)

optimalDfPath = "../results/2022_10_07_cc_NGA_year_0/data/optimalDf.csv"
sweepDirTop = "../results/2022_10_07_cc_NGA_year_0/sweep/"
infBrickPath = "../inputs/inf_rasters_processed/cc_NGA_year_0/outputs/brick.tif"
rewardRatio = 1

# ----------------------------------------------

optimalDf = read.csv(optimalDfPath)
infBrick = raster::brick(infBrickPath)

# detectionProbVec = c(0.01, 0.1, 0.25, 0.5, 0.85)
detectionProbVec = sort(unique(optimalDf$detectionProb))

iRes = 1
resDfList = list()
for(iRow in seq_len(nrow(optimalDf))){
    
    print(iRow)
    
    optimalRow = optimalDf[iRow,]


    # optimalRow = optimalDf[iRow,]

    sweepDir = file.path(sweepDirTop, paste0("sweep_", optimalRow$sweep_i), "outputs")

    # Read in final point structure
    coordsDfPath = file.path(sweepDir, "coordsDf.rds")
    traceDfPath = file.path(sweepDir, "traceDf.rds")

    # ---------------------------------
    # Pull out highest scoring iteration
    traceDf = readRDS(traceDfPath)

    traceDfMax = traceDf[traceDf$objective_func_val==max(traceDf$objective_func_val),]

    if(nrow(traceDfMax) > 1){
        traceDfMax = traceDfMax[traceDfMax$iteration == max(traceDfMax$iteration),]
    }

    coordsDf = readRDS(coordsDfPath) |>
        dplyr::filter(iteration == traceDfMax$iteration) |>
        dplyr::select(x, y)

    cellIndexVec = raster::cellFromXY(object=infBrick[[1]], xy=coordsDf)
    v_c = as.data.frame(infBrick[cellIndexVec])

    for(detectionProb in detectionProbVec){
        
        print(detectionProb)
        
        objVal = sa$objectiveFunc(
            brickValsDf=v_c, 
            rewardRatio=rewardRatio,
            detectionProb=detectionProb
        )
        
        resRow = data.frame(
            detectionProbTrained = optimalRow$detectionProb,
            numSurveysTrained = optimalRow$numSurveys,
            detectionProbTest = detectionProb,
            numSurveysTest = nrow(coordsDf),
            objVal = objVal
        )
        
        resDfList[[as.character(iRes)]] = resRow
        
        iRes = iRes + 1
        
    }

}

resDf = dplyr::bind_rows(resDfList)

# x = resDf |>
#     dplyr::filter(numSurveysTrained==1000)

dir.create("./points", showWarnings = FALSE, recursive=TRUE)
write.csv(resDf, "./points/resDf.csv", row.names=FALSE)
