library(ggplot2)

hostStatsDf = sf::read_sf("../../../../../inputs/inputs_raw/polygons/polys_cassava_host_CassavaMap.gpkg") |>
    sf::st_drop_geometry() |>
    dplyr::top_n(10, wt=cassava_host_num_fields) |>
    dplyr::arrange(-cassava_host_num_fields)

p = ggplot(hostStatsDf, aes(x=reorder(POLY_ID, cassava_host_num_fields), y=cassava_host_num_fields)) +
    geom_bar(stat = "identity") +
    xlab(NULL) +
    ylab("Number of cassava fields")

# p

ggsave(filename="./num_fields.png", plot=p)
