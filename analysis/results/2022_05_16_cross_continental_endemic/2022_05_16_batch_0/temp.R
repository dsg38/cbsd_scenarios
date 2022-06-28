infDf = readRDS("./output/raster_poly_stats_agg_minimal_DONE.rds")

passKeys = rjson::fromJSON(file="./output/cumulative_passKeys.json")

x = infDf |>
    dplyr::filter(raster_year == 2050 & POLY_ID=="NGA" & simKey %in% passKeys[["uga-RWA-BDI-drc_first_east-Pweto-zmb_regions_union-drc_north_central_field"]])

sum(x$raster_num_fields > 0) / nrow(x)
