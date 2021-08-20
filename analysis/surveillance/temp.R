box::use(dplyr[`%>%`])

# detectionDf = read.csv("./outputs//2021_03_26_cross_continental/results/detection_year.csv")

oldDf = readRDS("./outputs/2021_03_26_cross_continental/results/big_OLW.rds")

year_mapping_df = read.csv("./outputs/2021_03_26_cross_continental/sim_subset/year_mapping.csv")

survey_df = oldDf %>%
    dplyr::rename(raster_year=year) %>%
    dplyr::left_join(year_mapping_df, by=c("batch", "job", "raster_year"))

saveRDS(survey_df, "./outputs/2021_03_26_cross_continental/results/big.rds")
