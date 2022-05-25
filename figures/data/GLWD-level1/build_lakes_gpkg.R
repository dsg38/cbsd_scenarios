lakesDf =  sf::st_read("raw_data/glwd_1.shp", crs="WGS84")

lakesDfFixed = lakesDf[sf::st_is_valid(lakesDf),]

sf::write_sf(lakesDfFixed, "./lakes_glwd_1.gpkg")
