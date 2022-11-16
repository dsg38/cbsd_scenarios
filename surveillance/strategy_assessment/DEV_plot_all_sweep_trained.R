box::use(ggplot2[...])

# --------------------------------------------------------

numSurveysTrained = 1000

outDir = "./plots_stacked"
dir.create(outDir, showWarnings = FALSE, recursive = TRUE)

# Read in and standardise points
pointsDfRaw = read.csv("./data/pointsDf.csv")


detectionProbTrainedVec = sort(unique(pointsDfRaw$detectionProbTest))
for(detectionProbTrained in detectionProbTrainedVec){
    
    pointsDf = pointsDfRaw |>
        dplyr::filter(detectionProbTrained == !!detectionProbTrained & numSurveysTrained == !!numSurveysTrained) |>
        dplyr::mutate(cat="points_optimised")
    
    # Read in and standardise simple_grid / simple_clusters
    gridDf = read.csv("./data/simple_grid.csv") |>
        dplyr::filter(detectionProbTrained == !!detectionProbTrained & numSurveysTrained == !!numSurveysTrained) |>
        dplyr::mutate(cat="simple_grid")
    
    
    clusterDf = read.csv("./data/simple_clusters.csv")|>
        dplyr::filter(detectionProbTrained == !!detectionProbTrained & numSurveysTrained == !!numSurveysTrained) |>
        dplyr::mutate(cat="simple_clusters")
    
    # Read in and standardise real_world points 
    realPointsDf = read.csv("./real_world/outputs/cc_NGA_year_0/realWorldSurveyPerformance.csv") |>
        dplyr::filter(numSurveys==1090) |>
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



