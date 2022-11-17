box::use(ggplot2[...])

# simpleType = "simple_clusters"
simpleType = "simple_grid"

optimalDf = read.csv("../results/2022_10_07_cc_NGA_year_0/data/optimalDf.csv") |>
    dplyr::mutate(sweep_i = as.character(sweep_i)) |>
    dplyr::select(sweep_i, detectionProb, numSurveys) |>
    dplyr::rename(detectionProbTrained = detectionProb, numSurveysTrained=numSurveys, sweepIndex = sweep_i)

clusterDf = readRDS(file.path("./results/2022_10_07_cc_NGA_year_0/", simpleType,"/bigResultsDf.rds")) |>
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

# Save
dir.create("./data", showWarnings = FALSE, recursive=TRUE)
write.csv(simpleDf, file.path("./data/", paste0(simpleType, ".csv")), row.names = FALSE)


# Plot

simpleDf$detectionProbTest = as.factor(simpleDf$detectionProbTest)
simpleDf$detectionProbTrained = as.factor(simpleDf$detectionProbTrained)

simpleDfSubset = simpleDf[simpleDf$numSurveysTest==1000,]

p = ggplot(data=simpleDfSubset, aes(x=detectionProbTrained, y=objVal, colour=detectionProbTest, group=detectionProbTest)) +
    geom_point() +
    geom_line()
# p

outDir = "./plots"
dir.create(outDir, showWarnings = FALSE, recursive = TRUE)

outPathP = file.path(outDir, paste0(simpleType, "_sweep_trained.png"))
ggsave(filename=outPathP, plot=p)


q = ggplot(data=simpleDfSubset, aes(x=detectionProbTest, y=objVal, colour=detectionProbTrained, group=detectionProbTrained)) +
    geom_point() +
    geom_line()


outPathQ = file.path(outDir, paste0(simpleType, "_sweep_test.png"))
ggsave(filename=outPathQ, plot=q)

# q







