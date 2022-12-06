box::use(ggplot2[...])
box::use(./utils_assessment)

scenarioName = "2022_10_07_cc_NGA_year_0"

numSurveysTrained = 1000
numSurveysReal = 1090

# ---------------------------

inputsKey = utils_assessment$getConfigFromScenarioName(scenarioName)[["inputsKey"]]

resultsDir = file.path("./results/", scenarioName)

pointsDfPath = file.path(resultsDir, "/points/pointsDf.csv")
realPointsDfPath = file.path("./real_world/outputs/", inputsKey, "realWorldSurveyPerformance.csv")

outDir = file.path(resultsDir, "plots")

dir.create(outDir, recursive = TRUE, showWarnings = FALSE)

# ------------------------------
# Plot points
# ------------------------------

resDf = read.csv(pointsDfPath) |>
    dplyr::filter(numSurveysTrained==!!numSurveysTrained)

resDf$detectionProbTest = as.factor(resDf$detectionProbTest)
resDf$detectionProbTrained = as.factor(resDf$detectionProbTrained)

# Add real points performance
realPointsDf = read.csv(realPointsDfPath) |>
    dplyr::filter(numSurveys==numSurveysReal) |>
    dplyr::rename(detectionProbTest=detectionProb) |>
    dplyr::mutate(detectionProbTrained = "Real survey")

realPointsDf$detectionProbTest = as.factor(realPointsDf$detectionProbTest)

genPlot = function(
    resDf,
    realPointsDf,
    title,
    outPath
){

    p = ggplot(data=resDf, aes(x=detectionProbTest, y=objVal, colour=detectionProbTrained, group=detectionProbTrained)) +
        geom_point() +
        geom_line() +
        geom_point(data=realPointsDf) +
        geom_line(data=realPointsDf) +
        ggtitle(title)

    ggsave(filename=outPath, plot=p)

}

genPlot(
    resDf=resDf,
    realPointsDf=realPointsDf,
    title="Points",
    outPath=file.path(outDir, "points_sweep_test.png")
)

# ------------------------------
# Plot simple
# ------------------------------

simpleTypeVec = c("simple_grid", "simple_clusters")

for(simpleType in simpleTypeVec){

    simpleDfPath = file.path(resultsDir, simpleType, "bigResultsDf_median.rds")

    simpleDf = readRDS(simpleDfPath)

    # Plot
    simpleDf$detectionProbTest = as.factor(simpleDf$detectionProbTest)
    simpleDf$detectionProbTrained = as.factor(simpleDf$detectionProbTrained)

    simpleDfSubset = simpleDf[simpleDf$numSurveysTrained==numSurveysTrained,]

    genPlot(
        resDf=simpleDfSubset,
        realPointsDf=realPointsDf,
        title=simpleType,
        outPath=file.path(outDir, paste0(simpleType, "_sweep_test.png"))
    )

}


# p = ggplot(data=simpleDfSubset, aes(x=detectionProbTest, y=objVal, colour=detectionProbTrained, group=detectionProbTrained)) +
#     geom_point() +
#     geom_line() +
#     geom_point(data=realPointsDf) +
#     geom_line(data=realPointsDf) +
#     ggtitle("Points")

# p

# outPath = 
# ggsave(filename=outPath, plot=p)

