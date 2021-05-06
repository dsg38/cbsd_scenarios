box::use(./utils)

# Bind polys_0 output to polys_1
polys_0_df = sf::read_sf("../inputs_raw/polygons/polys_0_host_default.gpkg")

polyDfPathIn = "./gadm36_levels_gpkg/gadm36_level0_africa.gpkg"
hostRasterPath = "../inputs_raw/host_landscape/default/host.tif"

polyDfIn = sf::read_sf(polyDfPathIn)

africa_0_df = utils$appendHostStats(
    polyDfIn=polyDfIn,
    hostRasterPath=hostRasterPath
)

# Append POLY_ID col
africa_0_df_id = cbind(
    POLY_ID=africa_0_df$GID_0,
    africa_0_df
)

outDf = dplyr::bind_rows(
    polys_0_df,
    africa_0_df_id
)

polyDfPathOut = "../inputs_raw/polygons/polys_1_host_default.gpkg"
sf::write_sf(outDf, polyDfPathOut)
