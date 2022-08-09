box::use(./utils)

# Read in host raster
hostRasterPath = "../inputs_scenarios/2022_08_03_direct_intro_NGA_lagos/inputs/L_0_HOSTDENSITY.txt"

# Read in countries poly
countriesDf = sf::read_sf("./gadm36_levels_gpkg/gadm36_level0_africa.gpkg")

# Subset and rename polys
polysDfSubset = countriesDf |>
    dplyr::rename(POLY_ID=GID_0) |>
    dplyr::select(POLY_ID, geom)

polyDfStats = utils$appendHostStats(
    polyDfIn=countriesDf,
    hostRasterPath=hostRasterPath
) |>
    dplyr::filter(cassava_host_num_fields >= 1000) # Drop polys with <1000 fields

# Save
sf::write_sf(polyDfStats, "../inputs_raw/polygons/polys_direct_intro_host_CassavaMap.gpkg")
