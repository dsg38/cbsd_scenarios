x = readRDS("./output/management_results.rds")

# progDf = read.csv("../../../../simulations/sim_output/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/progress.csv")


# # x = readRDS("./output/raster_poly_stats_agg_minimal.rds")
# y = readRDS("./output/raster_poly_stats_agg_minimal_PRESENTDAY.rds")
# # z = readRDS("./output/raster_poly_stats_agg_minimal_DONE.rds")
# # 
# # 
# # length(unique(x$simKey))
# length(unique(y$simKey))
# # length(unique(z$simKey))


# sum(progDf$simTimeRemaining==0, na.rm = T)

# hist(progDf$simTimeRemaining, ylim=c(0, 100))

# sum(progDf$numRastersTif==51, na.rm=T)

# sum(progDf$dpcLastSimTime > 2018, na.rm=T)


# sum(progDf$numRastersTif>35, na.rm=T)

# 51 - 14

# sum(progDf$numRastersTxt>1, na.rm=T)

# # Any where dpc says finished but rasters not all tif
# progDfSubset = progDf[progDf$numRastersTxt>=1,]
