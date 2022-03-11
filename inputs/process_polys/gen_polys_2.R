box::use(./utils)

# Bind polys_0 output to polys_1
polys_1_df = sf::read_sf("../inputs_raw/polygons/polys_1_host_CassavaMap.gpkg")

hostRasterPath = "../inputs_raw/host_landscape/CassavaMap/host.tif"

africa_1_df = sf::read_sf("./gadm36_levels_gpkg/gadm36_level1_africa.gpkg")

africa_1_df = utils$appendHostStats(
    polyDfIn=africa_1_df,
    hostRasterPath=hostRasterPath
)

# Append POLY_ID col
africa_1_df_id = cbind(
    POLY_ID=africa_1_df$GID_1,
    africa_1_df
)

outDf = dplyr::bind_rows(
    polys_1_df,
    africa_1_df_id
)

polyDfPathOut = "../inputs_raw/polygons/polys_2_host_CassavaMap.gpkg"
sf::write_sf(outDf, polyDfPathOut)
