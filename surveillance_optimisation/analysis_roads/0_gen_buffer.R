bufferDistMVec = c(500, 1000, 2000)

for(bufferDistM in bufferDistMVec){

    print(bufferDistM)

    # Read in roads
    roadsDf = sf::read_sf("./data/raw/groads-v1-africa-gdb/gROADS-v1-africa.gdb")

    # Read in country polys
    countryDf = sf::read_sf("../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg") |>
        dplyr::filter(GID_0 == "NGA")

    # Crop roads
    roadsDfCropRaw = sf::st_intersection(roadsDf, countryDf)

    # Append length of roads
    road_length_km = as.numeric(sf::st_length(roadsDfCropRaw)) / 1000

    roadsDfCrop = roadsDfCropRaw |>
        dplyr::mutate(road_length_km=road_length_km)

    # dist is in metres
    roadsDfBuffer = sf::st_buffer(roadsDfCrop, dist=bufferDistM)

    sf::write_sf(roadsDfBuffer, file.path("./data/buffer/", paste0("groads_buffer_", bufferDistM, "m.gpkg")))

}
