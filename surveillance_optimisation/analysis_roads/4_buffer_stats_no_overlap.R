ngaPolyDf = sf::read_sf("../cbsd_scenarios/inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg") |>
    dplyr::filter(GID_0 == "NGA")

ngaAreaM2 = as.numeric(sf::st_area(ngaPolyDf))

# -----------------------

resList = list()

bufferDistMVec = c(500, 1000, 2000)
for(bufferDistM in bufferDistMVec){
    
    print(bufferDistM)
    
    roadsDfPath = file.path("./data/buffer/", paste0("groads_buffer_", bufferDistM, "m.gpkg"))
    
    roadsDf = sf::read_sf(roadsDfPath) 
    
    area_roads_m2_vec = roadsDf |>
        sf::st_union() |>
        sf::st_make_valid() |>
        sf::st_area()
    
    area_roads_m2 = as.numeric(area_roads_m2_vec[2])

    thisRow = data.frame(
        buffer_dist_m = bufferDistM,
        area_roads_m2 = area_roads_m2,
        prop_country = area_roads_m2 / ngaAreaM2
    )
    
    resList[[as.character(bufferDistM)]] = thisRow

}

resDf = dplyr::bind_rows(resList)

write.csv(resDf, "./results/buffer_stats_no_overlap.csv", row.names=FALSE)
