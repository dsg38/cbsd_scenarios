box::use(ggplot2[...])
box::use(./utils_assessment)

scenarioName = "2022_10_07_cc_NGA_year_0"

numSurveysTrained = 1000
numSurveysReal = 1090

# ---------------------------

inputsKey = utils_assessment$getConfigFromScenarioName(scenarioName)[["inputsKey"]]

pointsDfPath = file.path("./results/", scenarioName, "/points/pointsDf.csv")
realPointsDfPath = file.path("./real_world/outputs/", inputsKey, "realWorldSurveyPerformance.csv")

outDir = dirname(pointsDfPath)

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

p = ggplot(data=resDf, aes(x=detectionProbTest, y=objVal, colour=detectionProbTrained, group=detectionProbTrained)) +
    geom_point() +
    geom_line() +
    geom_point(data=realPointsDf) +
    geom_line(data=realPointsDf)

outPath = file.path(outDir, "points_sweep_test.png")
ggsave(filename=outPath, plot=p)
