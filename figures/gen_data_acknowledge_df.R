surveyData = read.csv("../../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.csv") |>
    dplyr::filter(!is.na(adult_whitefly_mean))

countDf = surveyData |>
    dplyr::group_by(country_code) |>
    dplyr::count()

# Append display names / drop code / rename n
dispDf = read.csv("../inputs/process_polys/outputs/poly_display_names.csv") |>
    dplyr::rename(country_code = POLY_ID)

outDf = dplyr::left_join(countDf, dispDf, by=c("country_code")) |>
    dplyr::ungroup() |>
    dplyr::select(c(display_name, n)) |>
    dplyr::rename()

write.csv(outDf, "./cassava_data_stats.csv", row.names = FALSE)
