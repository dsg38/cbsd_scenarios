rasterStatsDf = readRDS("./results/2021_03_26_cross_continental/2021_04_29_merged/output/raster_poly_stats_agg_minimal.rds")
catDf = read.csv("../inputs/process_polys/outputs/country_categories.csv")

polyIdVec = catDf$POLY_ID[catDf$waveBool | catDf$cdpBool | catDf$interestingBool]

# unique(maskBool$)
# maskBool = stringr::str_detect(rasterStatsDf$POLY_ID, "mask_")

keepBool = rasterStatsDf$POLY_ID %in% polyIdVec

rasterStatsDfSmall = rasterStatsDf[keepBool,]

saveRDS(rasterStatsDfSmall, "./results/2021_03_26_cross_continental/2021_04_29_merged/output/raster_poly_stats_agg_minimal_SMALL.rds")

