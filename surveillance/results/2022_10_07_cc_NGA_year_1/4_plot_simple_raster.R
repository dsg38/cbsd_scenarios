box::use(../../utils/utils_surveillance)

simpleDfDir = "./data/simple_grid"
targetCountryCode = "NGA"
optimalDfPath = "./data/optimalDf.csv"

breaks = seq(0, 0.3, 0.05)

# --------------------------------

simpleDfPaths = list.files(simpleDfDir, full.names = TRUE)

optimalDf = read.csv(optimalDfPath)

for(simpleDfPath in simpleDfPaths){

    gridName = tools::file_path_sans_ext(basename(simpleDfPath))

    sweepIndex = dplyr::last(stringr::str_split(gridName, "_")[[1]])

    plotPath = file.path("./plots/simple_grid/", paste0(gridName, ".png"))

    optimalDfRow = optimalDf[optimalDf$sweep_i == sweepIndex,]
    
    print(plotPath)
    
    utils_surveillance$plotSimpleGrid(
        simpleDfPath = simpleDfPath,
        targetCountryCode = targetCountryCode,
        optimalDfRow = optimalDfRow,
        breaks = breaks,
        plotPath = plotPath
    )

}
