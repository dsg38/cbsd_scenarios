progDf = read.csv("./simulations/sim_output/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/progress.csv")


sum(progDf$dpcLastSimTime == progDf$simEndTime, na.rm=TRUE)

sum(progDf$maxRasterYearTif == 2054, na.rm=TRUE)

sum(progDf$dpcLastSimTime>2039, na.rm=TRUE)


# hist(progDf$dpcLastSimTime)
# 
# 
# x = progDf |>
#     dplyr::filter(!is.na(dpcLastSimTime) & dpcLastSimTime!=2054)
# 
# hist(x$dpcLastSimTime)
# 
# 
# sort(unique(progDf$maxRasterYearTif))

processDf = progDf |>
    dplyr::filter(maxRasterYearTif != 2054)

# write.csv(processDf, "temp.csv", row.names=FALSE)


# stringr::str_detect(x, ".xml")

# x = sf::read_sf("./inputs/inputs_raw/polygons/polys_cross_continental_constraints_host_CassavaMap.gpkg")
# mapview::mapview(x)
# progDf$maxRasterYearTif

x = readRDS("./analysis/results/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/output/raster_poly_stats_agg.rds")
x$simKey[[1]]
