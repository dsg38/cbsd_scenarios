box::use(ggplot2[...])

# --------------------------------------------------------

numSurveysTrained = 1000

outDir = "./plots_stacked"
dir.create(outDir, showWarnings = FALSE, recursive = TRUE)

# Read in and standardise points
pointsDfRaw = read.csv("./data/pointsDf.csv")


detectionProbTestVec = sort(unique(pointsDfRaw$detectionProbTest))
for(detectionProbTest in detectionProbTestVec){
    
    pointsDf = pointsDfRaw |>
        dplyr::filter(detectionProbTest == !!detectionProbTest & numSurveysTrained == !!numSurveysTrained) |>
        dplyr::mutate(cat="points_optimised")
    
    # Read in and standardise simple_grid / simple_clusters
    gridDf = read.csv("./data/simple_grid.csv") |>
        dplyr::filter(detectionProbTest == !!detectionProbTest & numSurveysTrained == !!numSurveysTrained) |>
        dplyr::mutate(cat="simple_grid")
    
    
    clusterDf = read.csv("./data/simple_clusters.csv")|>
        dplyr::filter(detectionProbTest == !!detectionProbTest & numSurveysTrained == !!numSurveysTrained) |>
        dplyr::mutate(cat="simple_clusters")
    
    # Read in and standardise real_world points 
    # realPointsDf = read.csv("./real_world/outputs/cc_NGA_year_0/realWorldSurveyPerformance.csv") |>
    #     dplyr::filter(numSurveys==1090) |>
    #     dplyr::rename(detectionProbTest = detectionProb) |>
    #     dplyr::mutate(cat="points_real")
    # 
    
    # Merge with classifying key 
    stackedDf = dplyr::bind_rows(
        pointsDf,
        gridDf,
        clusterDf#,
        # realPointsDf
    )
    
    # Plot
    p = ggplot(data=stackedDf, aes(x=detectionProbTrained, y=objVal, colour=cat, group=cat)) +
        geom_point() +
        geom_line() +
        ggtitle(paste0("detectionProbTest: ", detectionProbTest)) +
        ylim(0, max(pointsDfRaw$objVal))

    # p
    # Save
    x = format(detectionProbTest, nsmall = 2)
    outPath = file.path(outDir, paste0("numSurveysTrained_", numSurveysTrained, "_detectionProbTest_", x, ".png"))
    ggsave(filename=outPath, plot=p)
    
    
    
    
}



