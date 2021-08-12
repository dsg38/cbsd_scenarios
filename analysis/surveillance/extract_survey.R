surveyDf = sf::read_sf("../../../cbsd_data/data/cube/cube.gpkg")

surveyDfSubset = surveyDf[surveyDf$country_code=="NGA" & surveyDf$year==2017,]

sf::write_sf(surveyDfSubset, "./outputs/survey_locations/real/NGA-2017.gpkg")
