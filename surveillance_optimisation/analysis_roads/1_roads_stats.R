# Read in roads buffer
roadsDf = sf::read_sf("./data/buffer/groads_buffer_500m.gpkg")

# Basic roads summary stats
fclassNumStatsDf = roadsDf |>
    sf::st_drop_geometry() |>
    dplyr::count(FCLASS) |>
    dplyr::mutate(prop = round(n / nrow(roadsDf), 2))

fclassLengthDf = roadsDf |>
    sf::st_drop_geometry() |>
    dplyr::group_by(FCLASS) |>
    dplyr::summarise(road_length_km_sum = sum(road_length_km)) |>
    dplyr::mutate(prop = round(road_length_km_sum / sum(road_length_km_sum), 2))

# Plot roads
sort(unique(roadsDf$FCLASS))
mapview::mapview(roadsDf[roadsDf$FCLASS==6,])
