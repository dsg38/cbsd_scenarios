gridRes = 20

resultsDir = "./sweep/results/sweep_1/"
countryCode = "COG"

coordsDfPath = file.path(resultsDir, "coordsDf.rds")
traceDfPath = file.path(resultsDir, "traceDf.rds")

# Read in poly defining extent
polyDf = sf::read_sf("../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg") |>
    dplyr::filter(GID_0==countryCode)
    
polyExtent = sf::st_bbox(polyDf)

# ---------------------------------
# Pull out highest scoring iteration
traceDf = readRDS(traceDfPath)

traceDfMax = traceDf[traceDf$objective_func_val==max(traceDf$objective_func_val),]

if(nrow(traceDfMax) > 1){
    traceDfMax = traceDfMax[traceDfMax$iteration == max(traceDfMax$iteration),]
}

coordsDf = readRDS(coordsDfPath) |>
    dplyr::filter(iteration == traceDfMax$iteration) |>
    sf::st_as_sf(coords=c("x", "y"), crs="WGS84")

coordsDf$coord_id = paste0("point_", seq(1, nrow(coordsDf)))

# Rasterise poly extent at given resolution
gridDf = sf::st_make_grid(x=polyExtent, n=gridRes) |> 
    sf::st_sf()

colnames(gridDf) = "geom"

gridDf = cbind(POLY_ID=paste0("grid_", seq_len(nrow(gridDf))), gridDf)


# Crop polys to intersect with target country / poly
gridDfIntersect = sf::st_intersection(x=gridDf, y=polyDf) |>
    dplyr::select(POLY_ID, geom)

# Calculate the number of survey points (coordsDf) per raster cell
coordGridDf = sf::st_intersection(x = gridDfIntersect, y = coordsDf) |>
    sf::st_drop_geometry() |>
    dplyr::group_by(POLY_ID) |>
    dplyr::count()

gridStatsDf = dplyr::left_join(gridDfIntersect, coordGridDf, by=c("POLY_ID"))

gridStatsDf$n[is.na(gridStatsDf$n)] = 0

# Calculate prop
gridStatsDf$prop = gridStatsDf$n / sum(gridStatsDf$n)

# Save
outPath = file.path(resultsDir, paste0("simple_gridRes_", gridRes, ".gpkg"))
sf::write_sf(gridStatsDf, outPath)

# mapview::mapview(gridStatsDf, z="n") + mapview::mapview(coordsDf, hide=TRUE)
