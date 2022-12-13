box::use(../../utils/utils_surveillance)

optimalDfPath = "./data/optimalDf.csv"

optimalDf = read.csv(optimalDfPath)

# Read in country polys
statePolysDf = sf::read_sf("../../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level1_africa.gpkg")

countryPolysDf = sf::read_sf("../../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg")

# Get extent
targetCountryCode = "NGA"

extentDf = countryPolysDf |>
    dplyr::filter(GID_0 == targetCountryCode)

extentBbox = sf::st_bbox(extentDf)

for(iRow in seq_len(nrow(optimalDf))){

    optimalDfRow = optimalDf[iRow,]

    plotPath = file.path("./plots/points/", paste0(paste0("sweep_", optimalDfRow$sweep_i), ".png"))

    utils_surveillance$plotPoints(
        optimalDfRow=optimalDfRow,
        extentBbox=extentBbox,
        statePolysDf=statePolysDf,
        countryPolysDf=countryPolysDf,
        plotPath=plotPath
    )

}
