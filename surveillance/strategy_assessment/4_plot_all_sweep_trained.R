box::use(ggplot2[...])
box::use(./utils_assessment)

scenarioName = "2022_10_07_cc_NGA_year_0"
numSurveysTrained = 1000
numSurveysReal = 1090

# --------------------------------------------------------

resultsDir = file.path("./results", scenarioName)

pointsDfRawPath = file.path(resultsDir, "points/pointsDf.csv")
gridDfPath = file.path(resultsDir, "simple_grid/bigResultsDf_median.rds")
clusterDfPath = file.path(resultsDir, "simple_clusters/bigResultsDf_median.rds")

inputsKey = utils_assessment$getConfigFromScenarioName(scenarioName)[["inputsKey"]]
realPointsDfPath = file.path("./real_world/outputs/", inputsKey, "/realWorldSurveyPerformance.csv")

outDir = file.path(resultsDir, "plots_stacked")

# ----------------------------------------------

dir.create(outDir, showWarnings = FALSE, recursive = TRUE)

# Read in and standardise points
pointsDfRaw = read.csv(pointsDfRawPath)

detectionProbTrainedVec = sort(unique(pointsDfRaw$detectionProbTest))
for(detectionProbTrained in detectionProbTrainedVec){
    
    pointsDf = pointsDfRaw |>
        dplyr::filter(detectionProbTrained == !!detectionProbTrained & numSurveysTrained == !!numSurveysTrained) |>
        dplyr::mutate(cat="points_optimised")
    
    # Read in and standardise simple_grid / simple_clusters
    gridDf = readRDS(gridDfPath) |>
        dplyr::filter(detectionProbTrained == !!detectionProbTrained & numSurveysTrained == !!numSurveysTrained) |>
        dplyr::mutate(cat="simple_grid")
    
    clusterDf = readRDS(clusterDfPath)|>
        dplyr::filter(detectionProbTrained == !!detectionProbTrained & numSurveysTrained == !!numSurveysTrained) |>
        dplyr::mutate(cat="simple_clusters")
    
    # Read in and standardise real_world points 
    realPointsDf = read.csv(realPointsDfPath) |>
        dplyr::filter(numSurveys==numSurveysReal) |>
        dplyr::rename(detectionProbTest = detectionProb) |>
        dplyr::mutate(cat="points_real")
    
    # Merge with classifying key 
    stackedDf = dplyr::bind_rows(
        pointsDf,
        gridDf,
        clusterDf,
        realPointsDf
    )
    
    # Plot
    p = ggplot(data=stackedDf, aes(x=detectionProbTest, y=objVal, colour=cat, group=cat)) +
        geom_point() +
        geom_line() +
        ggtitle(paste0("detectionProbTrained: ", detectionProbTrained)) +
        ylim(0, max(pointsDfRaw$objVal))
    
    # p
    # Save
    x = format(detectionProbTrained, nsmall = 2)
    outPath = file.path(outDir, paste0("numSurveysTrained_", numSurveysTrained, "_detectionProbTrained_", x, ".png"))
    ggsave(filename=outPath, plot=p)
    
}
