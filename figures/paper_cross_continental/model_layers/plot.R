surveyDfWhitefly = sf::read_sf("../../../../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.gpkg") |>
    dplyr::filter(!is.na(adult_whitefly_mean))

# Calc the num surveys per country
surveyCountsDf = surveyDfWhitefly |>
    sf::st_drop_geometry() |>
    dplyr::count(country_code)

print(sum(surveyCountsDf[surveyCountsDf$country_code!="UGA","n"]))

# Plot whitefly data locations


# Plot the host / vector layers
