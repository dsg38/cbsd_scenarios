cumulativePassKeys = rjson::fromJSON(file="./output/cumulative_passKeys.json")

for(thisKey in names(cumulativePassKeys)){
    
    print(thisKey)
    print(length(cumulativePassKeys[[thisKey]]))
    
}



# x = readRDS("./output/raster_poly_stats_agg_minimal_DONE.rds")
# y = readRDS("./output/propYearDf.rds")


# a = x |>
#     dplyr::filter(raster_year==2005 & POLY_ID=="UGA")

# sum(a$raster_prop_fields > 0)


# b = y |>
#     dplyr::filter(POLY_ID=="UGA" & prop==0)

# sum(b$raster_year==2005)

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
