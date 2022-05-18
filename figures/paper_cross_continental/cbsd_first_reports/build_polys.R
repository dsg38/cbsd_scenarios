x = sf::read_sf("../../../inputs/inputs_raw/polygons/polys_cross_continental_constraints_host_CassavaMap.gpkg")

kamDf = data.frame(
    POLY_ID="kampala",
    latitude=0.3476,
    longitude=32.5825
) |>
    sf::st_as_sf(coords=c("longitude", "latitude"), crs="WGS84") |>
    dplyr::rename(geom=geometry)


bufferDf = sf::st_buffer(kamDf, dist=100000)

y = dplyr::bind_rows(x, bufferDf)

sf::write_sf(y, "./inputs/target_polys.gpkg")
