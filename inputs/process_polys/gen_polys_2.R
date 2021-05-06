box::use(./utils)

# Bind polys_0 output to polys_1
polys_1_df = sf::read_sf("../inputs_raw/polygons/polys_1_host_default.gpkg")

hostRasterPath = "../inputs_raw/host_landscape/default/host.tif"

# africa_0_df = sf::read_sf("./gadm36_levels_gpkg/gadm36_level0_africa.gpkg")

# africa_0_df = utils$appendHostStats(
#     polyDfIn=africa_0_df,
#     hostRasterPath=hostRasterPath
# )

africa_1_df = sf::read_sf("./gadm36_levels_gpkg/gadm36_level1_africa.gpkg")

africa_1_df = utils$appendHostStats(
    polyDfIn=africa_1_df,
    hostRasterPath=hostRasterPath
)

outDf = dplyr::bind_rows(
    polys_1_df,
    africa_1_df
)

polyDfPathOut = "../inputs_raw/polygons/polys_2_host_default.gpkg"
sf::write_sf(outDf, polyDfPathOut)
