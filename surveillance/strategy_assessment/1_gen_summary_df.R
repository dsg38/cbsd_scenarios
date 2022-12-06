box::use(ggplot2[...])

scenarioName = "2022_10_07_cc_NGA_year_0"

simpleType = "simple_clusters"
# simpleType = "simple_grid"

# -------------------------
resultsDir = file.path("../results/", scenarioName)

optimalDfPath = file.path(resultsDir, "/data/optimalDf.csv")
clusterDfPath = file.path("./results/", scenarioName, simpleType, "bigResultsDf.rds")

simpleDfOutPath = file.path(dirname(clusterDfPath), "bigResultsDf_median.rds")

# --------------------------

optimalDf = read.csv(optimalDfPath) |>
    dplyr::mutate(sweep_i = as.character(sweep_i)) |>
    dplyr::select(sweep_i, detectionProb, numSurveys) |>
    dplyr::rename(detectionProbTrained = detectionProb, numSurveysTrained=numSurveys, sweepIndex = sweep_i)

clusterDf = readRDS(clusterDfPath) |>
    dplyr::rename(detectionProbTest = detectionProb, numSurveysTest = numSurveys)

mergedDf = dplyr::left_join(clusterDf, optimalDf, by=c("sweepIndex"))

numSurveysVec = sort(unique(mergedDf$numSurveysTrained))
detectionProbVec = sort(unique(mergedDf$detectionProbTrained))

rowCount = 1
simpleDfList = list()
for(numSurveys in numSurveysVec){
    
    for(detectionProbTrained in detectionProbVec){
        
        for(detectionProbTest in detectionProbVec){
            
            boolA = mergedDf$numSurveysTrained == numSurveys
            boolB = mergedDf$numSurveysTest == numSurveys
            boolC = mergedDf$detectionProbTrained == detectionProbTrained
            boolD = mergedDf$detectionProbTest == detectionProbTest
            
            boolAll = boolA & boolB & boolC & boolD
            
            mergedDfSubset = mergedDf[boolAll,]
            
            # Calculate the median and save the core data as single row
            objVal = median(mergedDfSubset$vals)

            outRow = data.frame(
                numSurveysTrained=numSurveys,
                numSurveysTest=numSurveys,
                detectionProbTrained=detectionProbTrained,
                detectionProbTest=detectionProbTest,
                objVal=objVal
            )
            
            simpleDfList[[as.character(rowCount)]] = outRow
            
            rowCount = rowCount + 1

        }
        
    }
    
}

simpleDf = dplyr::bind_rows(simpleDfList)

saveRDS(simpleDf, simpleDfOutPath)
