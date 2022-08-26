gridRes = 40

coordsDf = readRDS("./results/2022_08_26_test/coordsDf.rds") |>
    dplyr::filter(iteration == max(iteration)) |>
    sf::st_as_sf(coords=c("x", "y"), crs="WGS84")

# Read in country poly
polyDf = sf::read_sf("../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg") |>
    dplyr::filter(GID_0=="NGA")

# Rasterise poly extent at given resolution
polyExtent = sf::st_bbox(polyDf)

gridDf = sf::st_make_grid(x=polyExtent, n=gridRes) |> 
    sf::st_sf()

colnames(gridDf) = "geom"

gridDf = cbind(POLY_ID=paste0("grid_", seq_len(nrow(gridDf))), gridDf)

# TODO: Calculate the number of survey points (coordsDf) per raster cell
# Calculate host landscape stats per polygon
# gridDfHostStats = gridDf |>
#     dplyr::mutate(area_km2=as.numeric(units::set_units(sf::st_area(geom), km^2))) |> # Calculate area and convert to km^2
#     utils_epidem$appendHostStats(hostRasterPath = hostRasterPath) |> # Add some stats on cassava production 
#     dplyr::mutate(fields_per_km2 = cassava_host_num_fields / area_km2) |>
#     dplyr::filter(cassava_host_num_fields >= minNumFieldsPerPolyForHostStats) # Drop grids where 
# 
