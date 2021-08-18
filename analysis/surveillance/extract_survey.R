surveyDf = sf::read_sf("../../../cbsd_data/data/cube/cube.gpkg")

surveyDfSubset = surveyDf[surveyDf$country_code=="NGA" & surveyDf$year==2017,]

sf::write_sf(surveyDfSubset, "./outputs/2021_03_26_cross_continental/survey_locations/host_real/survey_real/NGA-2017.gpkg")
