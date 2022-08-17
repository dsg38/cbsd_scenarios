library(ggplot2)

surveyDfPath = "../../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.gpkg"

surveyDf = sf::read_sf(surveyDfPath) |>
    dplyr::filter(country_code=="UGA") |>
    dplyr::filter(!is.na(adult_whitefly_mean))

surveyDf$year = as.character(surveyDf$year)

p = ggplot(surveyDf, aes(x=year, y=adult_whitefly_mean)) + 
    geom_boxplot() + 
    ylim(0, 50)

p
