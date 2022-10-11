box::use(../../utils/utils_surveillance)

simpleDfDir = "./data/simple_grid"
targetCountryCode = "NGA"
optimalDfPath = "./data/optimalDf.csv"

# --------------------------------

simpleDfPaths = list.files(simpleDfDir, full.names = TRUE)

optimalDf = read.csv(optimalDfPath)

for(simpleDfPath in simpleDfPaths){

    gridName = tools::file_path_sans_ext(basename(simpleDfPath))

    sweepIndex = dplyr::last(stringr::str_split(gridName, "_")[[1]])

    plotPath = file.path("./plots/simple_grid/", paste0(gridName, ".png"))

    optimalDfRow = optimalDf[optimalDf$sweep_i == sweepIndex,]

    plotTitle = paste0("numSurveys: ", optimalDfRow$numSurveys, " | detectionProb: ", optimalDfRow$detectionProb, " | objFuncVal: ", round(optimalDfRow$objective_func_val, 2))
    
    print(plotPath)
    
    utils_surveillance$plotSimpleGrid(
        simpleDfPath = simpleDfPath,
        targetCountryCode = targetCountryCode,
        plotTitle = plotTitle,
        plotPath = plotPath
    )

}
