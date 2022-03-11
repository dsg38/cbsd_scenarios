box::use(utils_epidem/utils_epidem)

polys_1_df = sf::read_sf("../inputs_raw/polygons/polys_1_host_CassavaMap.gpkg")

africaCassavaPolysDf = dplyr::filter(polys_1_df, GID_0 %in% utils_epidem$africaCassavaCountryCodes)

sf::write_sf(africaCassavaPolysDf, "../inputs_raw/polygons/polys_cassava_host_CassavaMap.gpkg")
