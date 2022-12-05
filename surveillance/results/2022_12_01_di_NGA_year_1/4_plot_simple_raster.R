box::use(../../utils/utils_surveillance)
tmap::tmap_options(check.and.fix = TRUE)

genStackedSfDf = function(simpleDfDir){

    x = list.files(simpleDfDir, "*.gpkg", full.names = TRUE)

    stackdDfList = list()
    for(thisPath in x){
        stackdDfList[[thisPath]] = sf::read_sf(thisPath)    
    }

    stackedDf = dplyr::bind_rows(stackdDfList)

    return(stackedDf)

}

# --------------------------------
# GRID CHUNK
# --------------------------------

simpleDfDir = "./data/simple_grid"

targetCountryCode = "NGA"

countryPolysDf = sf::read_sf("../../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg")

# Extent poly
extentDf = countryPolysDf |>
    dplyr::filter(GID_0 == targetCountryCode)

stackedDf = genStackedSfDf(simpleDfDir)

extentBbox = sf::st_bbox(extentDf)

# ---------------------------------
# CLUSTERS CHUNK
# --------------------------------

# simpleDfDir = "./data/simple_clusters"

# stackedDf = genStackedSfDf(simpleDfDir)

# extentBbox = sf::st_bbox(stackedDf)



# --------------------------------
# --------------------------------
# --------------------------------
# --------------------------------

optimalDfPath = "./data/optimalDf.csv"

breaks = seq(0, max(stackedDf$prop) +  0.05, 0.05)

legendPos = c("right", "bottom")

simpleDfPaths = list.files(simpleDfDir, full.names = TRUE)

optimalDf = read.csv(optimalDfPath)

for(simpleDfPath in simpleDfPaths){

    gridName = tools::file_path_sans_ext(basename(simpleDfPath))

    sweepIndex = dplyr::last(stringr::str_split(gridName, "_")[[1]])

    plotPath = file.path("./plots", basename(simpleDfDir), paste0(gridName, ".png"))

    optimalDfRow = optimalDf[optimalDf$sweep_i == sweepIndex,]
    
    print(plotPath)
    
    utils_surveillance$plotSimpleGrid(
        simpleDfPath = simpleDfPath,
        extentBbox = extentBbox,
        optimalDfRow = optimalDfRow,
        breaks = breaks,
        legendPos = legendPos,
        plotPath = plotPath
    )

}
