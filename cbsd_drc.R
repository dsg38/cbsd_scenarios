cassavaDf = sf::read_sf("../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.gpkg") |> 
    dplyr::filter(country_code=="COD")

mapview::mapview(cassavaDf)

cassavaDfPos = cassavaDf |>
    dplyr::filter(cbsd_foliar_bool==TRUE)

mapview::mapview(cassavaDfPos)

unique(cassavaDfPos$year)

x = cassavaDfPos |>
    dplyr::count(year)

cassavaPos2015 = cassavaDfPos |>
    dplyr::filter(year==2015)

mapview::mapview(cassavaPos2015)

x = cassavaPos2015[cassavaPos2015$merged_id=="merged_id_13290",]


y = cassavaDf |>
    dplyr::filter(
        country_code=="COD",
        year==2015
        # cbsd_root_bool==TRUE
    )

mapview::mapview(y)
