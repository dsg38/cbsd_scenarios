surveyDfRaw = read.csv("../../cbsd_landscape_model/input_generation/surveillance_data/raw_data/survey_data_summary_codes.csv")

surveyDf = sf::st_as_sf(surveyDfRaw, coords=c("x", "y"))

sf::write_sf(surveyDf, "data/survey_data.gpkg")