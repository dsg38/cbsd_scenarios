medianInWhichYear = 5

polyStatsDf = readRDS("./output/raster_poly_stats_agg_minimal_DONE.rds") |>
    dplyr::filter(POLY_ID=="NGA" & raster_year==medianInWhichYear) |>
    dplyr::arrange(raster_prop_fields)

medianIndex = ceiling(nrow(polyStatsDf) / 2)

x = polyStatsDf[medianIndex,]

print(x$job)
