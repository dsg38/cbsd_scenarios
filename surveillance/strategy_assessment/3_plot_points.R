box::use(ggplot2[...])
box::use(./utils_assessment)

# scenarioNameTarget = "2022_10_07_cc_NGA_year_0"
# scenarioNameTest = "2022_10_07_cc_NGA_year_0"

# scenarioNameTarget = "2022_12_01_di_NGA_year_1"
# scenarioNameTest = "2022_12_01_di_NGA_year_1"

# scenarioNameTarget = "2022_12_01_di_NGA_year_1"
# scenarioNameTest = "2022_10_07_cc_NGA_year_0"

scenarioNameTarget = "2022_10_07_cc_NGA_year_0"
scenarioNameTest = "2022_12_01_di_NGA_year_1"

# --------------------------

numSurveysTrained = 1000
numSurveysReal = 1090

# ---------------------------
assessmentResultsDir = paste0("target_", scenarioNameTarget, "_test_", scenarioNameTest)

resultsDir = file.path("./results/", assessmentResultsDir)

pointsDfPath = file.path(resultsDir, "/points/pointsDf.csv")

outDir = file.path(resultsDir, "plots")

dir.create(outDir, recursive = TRUE, showWarnings = FALSE)

# ------------------------------
# Plot points
# ------------------------------

resDf = read.csv(pointsDfPath) |>
    dplyr::filter(numSurveysTrained==!!numSurveysTrained)

resDf$detectionProbTest = as.factor(resDf$detectionProbTest)
resDf$detectionProbTrained = as.factor(resDf$detectionProbTrained)


parseRealDf = function(scenarioName){

    inputsKey = utils_assessment$getConfigFromScenarioName(scenarioName)[["inputsKey"]]

    realPointsDfPath = file.path("./real_world/outputs/", inputsKey, "realWorldSurveyPerformance.csv")

    # Add real points performance
    realPointsDf = read.csv(realPointsDfPath) |>
        dplyr::filter(numSurveys==numSurveysReal) |>
        dplyr::rename(detectionProbTest=detectionProb) |>
        dplyr::mutate(detectionProbTrained = paste0("Real survey"))

    realPointsDf$detectionProbTest = as.factor(realPointsDf$detectionProbTest)
    realPointsDf$detectionProbTrained = as.factor(realPointsDf$detectionProbTrained)
    
    return(realPointsDf)

}

realPointsDfTest = parseRealDf(scenarioNameTest)

genPlot = function(
    resDf,
    realPointsDfTest,
    title,
    outPath
){

    p = ggplot(data=resDf, aes(x=detectionProbTest, y=objVal, colour=detectionProbTrained, group=detectionProbTrained)) +
        geom_point() +
        geom_line() +
        geom_point(data=realPointsDfTest) +
        geom_line(data=realPointsDfTest) +
        ggtitle(title)
    
    ggsave(filename=outPath, plot=p)

}

genPlot(
    resDf=resDf,
    realPointsDfTest,
    title="Points",
    outPath=file.path(outDir, "points_sweep_test.png")
)

# ------------------------------
# Plot simple
# ------------------------------

# simpleTypeVec = c("simple_grid", "simple_clusters")

# for(simpleType in simpleTypeVec){

#     simpleDfPath = file.path(resultsDir, simpleType, "bigResultsDf_median.rds")

#     simpleDf = readRDS(simpleDfPath)

#     # Plot
#     simpleDf$detectionProbTest = as.factor(simpleDf$detectionProbTest)
#     simpleDf$detectionProbTrained = as.factor(simpleDf$detectionProbTrained)

#     simpleDfSubset = simpleDf[simpleDf$numSurveysTrained==numSurveysTrained,]

#     genPlot(
#         resDf=simpleDfSubset,
#         realPointsDf=realPointsDf,
#         title=simpleType,
#         outPath=file.path(outDir, paste0(simpleType, "_sweep_test.png"))
#     )

# }


# p = ggplot(data=simpleDfSubset, aes(x=detectionProbTest, y=objVal, colour=detectionProbTrained, group=detectionProbTrained)) +
#     geom_point() +
#     geom_line() +
#     geom_point(data=realPointsDf) +
#     geom_line(data=realPointsDf) +
#     ggtitle("Points")

# p

# outPath = 
# ggsave(filename=outPath, plot=p)

