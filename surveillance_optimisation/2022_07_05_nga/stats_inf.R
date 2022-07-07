# infRasterPaths = list.files(
#     path="./inf_rasters/raw/",
#     pattern=".*-0.tif",
#     recursive = TRUE,
#     full.names = TRUE
# )
# 
# # for(infRasterPath in infRasterPaths){
# #     
# # }
# 
# infRasterPath = infRasterPaths[[1]]
# infRaster = raster::raster(infRasterPath)
# 

dpcDf = read.csv("./data/dpcDf.csv") |>
    dplyr::filter(year_standardised==0)

hist(dpcDf$raster_prop_fields)

sum(dpcDf$raster_prop_fields > 0.01) / nrow(dpcDf)
