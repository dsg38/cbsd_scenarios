box::use(../utils/sa)
box::use(./utils_assessment)

# ----------------------------------------------
# Calculate the performance of a given optimal point structures (trained at a
# specified detectionProb) at different detectionProb.
# ----------------------------------------------

# scenarioNameTarget = "2022_10_07_cc_NGA_year_0"
# scenarioNameTest = "2022_10_07_cc_NGA_year_0"

# scenarioNameTarget = "2022_12_01_di_NGA_year_1"
# scenarioNameTest = "2022_12_01_di_NGA_year_1"

# scenarioNameTarget = "2022_12_01_di_NGA_year_1"
# scenarioNameTest = "2022_10_07_cc_NGA_year_0"

scenarioNameTarget = "2022_10_07_cc_NGA_year_0"
scenarioNameTest = "2022_12_01_di_NGA_year_1"

# ----------------------------------------------
# Get optimal sweep from 
resultsDir = file.path("../results/", scenarioNameTarget)

optimalDfPath = file.path(resultsDir, "/data/optimalDf.csv")
sweepDirTop = file.path(resultsDir, "/sweep/")

# Read in infBrick for target
configList = utils_assessment$getConfigFromScenarioName(scenarioNameTest)

inputsKey = configList[["inputsKey"]]

infBrickPath = file.path("../inputs/inf_rasters_processed/", inputsKey,"/outputs/brick.tif")


# ----------------------

outPath = file.path("./results/", paste0("target_", scenarioNameTarget, "_test_", scenarioNameTest), "/points/pointsDf.csv")

dir.create(dirname(outPath), showWarnings = FALSE, recursive=TRUE)

# ----------------------------------------------


rewardRatio = 1

optimalDf = read.csv(optimalDfPath)
infBrick = raster::brick(infBrickPath)

detectionProbVec = sort(unique(optimalDf$detectionProb))

iRes = 1
resDfList = list()
for(iRow in seq_len(nrow(optimalDf))){
    
    print(iRow)
    print(nrow(optimalDf))

    optimalRow = optimalDf[iRow,]

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
            objVal = objVal,
            scenarioNameTarget = scenarioNameTarget,
            scenarioNameTest = scenarioNameTest
        )
        
        resDfList[[as.character(iRes)]] = resRow
        
        iRes = iRes + 1
        
    }

}

resDf = dplyr::bind_rows(resDfList)

write.csv(resDf, outPath, row.names=FALSE)
