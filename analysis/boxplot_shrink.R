rasterStatsDf = readRDS("./results/2021_03_26_cross_continental/2021_04_29_merged/output/raster_poly_stats_agg_minimal.rds")

maskBool = stringr::str_detect(rasterStatsDf$POLY_ID, "mask_")

rasterStatsDfSmall = rasterStatsDf[maskBool,]

saveRDS(rasterStatsDfSmall, "./results/2021_03_26_cross_continental/2021_04_29_merged/output/raster_poly_stats_agg_minimal_SMALL.rds")