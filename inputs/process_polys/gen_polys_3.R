box::use(./utils)

# Bind polys_0 output to polys_1
polys_0_df = sf::read_sf("../inputs_raw/polygons/polys_0_host_default.gpkg")

# mapview::mapview(polys_0_df)
hostRasterPath = "../inputs_raw/host_landscape/default/host.tif"

africaDfPath = "./gadm36_levels_gpkg/gadm36_level1_africa.gpkg"
africaDf = sf::read_sf(africaDfPath)

africaDfSubset = africaDf[africaDf$GID_0 %in% c("ZMB", "COD"),]

africaDfHost = utils$appendHostStats(
    polyDfIn=africaDfSubset,
    hostRasterPath=hostRasterPath
)

# Append POLY_ID col
africaDfHostId = cbind(
    POLY_ID=africaDfHost$GID_1,
    africaDfHost
)

outDf = dplyr::bind_rows(
    polys_0_df,
    africaDfHostId
)

polyDfPathOut = "../inputs_raw/polygons/polys_3_host_default.gpkg"
sf::write_sf(outDf, polyDfPathOut)
