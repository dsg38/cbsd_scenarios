ngaPolyDf = sf::read_sf("../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg") |>
    dplyr::filter(GID_0 == "NGA")

ngaAreaM2 = as.numeric(sf::st_area(ngaPolyDf))

# -----------------------

resList = list()

bufferDistMVec = c(500, 1000, 2000)
for(bufferDistM in bufferDistMVec){
    
    print(bufferDistM)
    
    roadsDfPath = file.path("./data/buffer/", paste0("groads_buffer_", bufferDistM, "m.gpkg"))
    
    area_roads_m2 = sf::read_sf(roadsDfPath) |>
        sf::st_area() |>
        sum()
    
    thisRow = data.frame(
        buffer_dist_m = bufferDistM,
        area_roads_m2 = as.numeric(area_roads_m2),
        prop_country = as.numeric(area_roads_m2) / ngaAreaM2
    )
    
    resList[[as.character(bufferDistM)]] = thisRow
    
    
}

resDf = dplyr::bind_rows(resList)

write.csv(resDf, "./results/buffer_stats_overlap.csv", row.names=FALSE)
