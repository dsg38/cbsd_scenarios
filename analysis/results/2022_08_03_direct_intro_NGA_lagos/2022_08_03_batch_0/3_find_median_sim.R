medianInWhichYear = 5

polyStatsDf = readRDS("./output/raster_poly_stats_agg_minimal.rds") |>
    dplyr::filter(POLY_ID=="NGA" & raster_year==medianInWhichYear)

m = median(polyStatsDf$raster_prop_fields)

x = polyStatsDf[polyStatsDf$raster_prop_fields==m,]

print(x$job)
