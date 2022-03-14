x = sf::read_sf("../inputs/inputs_raw/polygons/polys_cassava_endemic_host_CassavaMap.gpkg")
sf::st_geometry(x) = NULL

x$POLY_ID
