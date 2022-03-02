# Define endemic country codes
endemicCountryCodes = c(
    "KEN",
    "TZA",
    "MOZ",
    "MWI"
)

# Read in survey points and extract CBSD positives
surveyDf = sf::read_sf("../../../../../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.gpkg") |>
    dplyr::filter(country_code %in% endemicCountryCodes) |>
    dplyr::filter(cbsd_any_bool==TRUE)



# mapview::mapview(endemicDf) + mapview::mapview(surveyDfSubset, zcol="year")
