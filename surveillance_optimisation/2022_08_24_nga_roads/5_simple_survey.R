gridRes = 10

coordsDf = readRDS("./results/2022_08_26_test/coordsDf.rds") |>
    dplyr::filter(iteration == max(iteration)) |>
    sf::st_as_sf(coords=c("x", "y"), crs="WGS84")

coordsDf$coord_id = paste0("point_", seq(1, nrow(coordsDf)))

# Read in country poly
polyDf = sf::read_sf("../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg") |>
    dplyr::filter(GID_0=="NGA")

# Rasterise poly extent at given resolution
polyExtent = sf::st_bbox(polyDf)

gridDf = sf::st_make_grid(x=polyExtent, n=gridRes) |> 
    sf::st_sf()

colnames(gridDf) = "geom"

gridDf = cbind(POLY_ID=paste0("grid_", seq_len(nrow(gridDf))), gridDf)

# Calculate the number of survey points (coordsDf) per raster cell
coordGridDf = sf::st_intersection(x = gridDf, y = coordsDf) |>
    sf::st_drop_geometry() |>
    dplyr::group_by(POLY_ID) |>
    dplyr::count()

gridStatsDf = dplyr::left_join(gridDf, coordGridDf, by=c("POLY_ID"))

gridStatsDf$n[is.na(gridStatsDf$n)] = 0

# Calculate prop
gridStatsDf$prop = gridStatsDf$n / sum(gridStatsDf$n)

# Plot
mapview::mapview(gridStatsDf, z="prop") + mapview::mapview(coordsDf, hide=TRUE)
