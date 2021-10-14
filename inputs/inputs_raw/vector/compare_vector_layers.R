rasterA = raster::raster("./default/vector.tif")
rasterB = raster::raster("./default_regen/idw_raster_param_1_data_C.tif")

# identical(rasterA, rasterB)

# rasterARound = round(rasterA, 2)
# rasterBRound = round(rasterB, 2)
# 
# identical(rasterARound, rasterBRound)


diffRaster = rasterB - rasterA
raster::plot(diffRaster)

x = diffRaster[][diffRaster[] > 0]
# hist(x)
max(x)

rev(sort(x))[1:10]

hist(rasterA[], xlim=c(0,1))
hist(rasterB[], xlim=c(0,1))
hist(diffRaster[], xlim=c(0,1))

raster::writeRaster(diffRaster, filename = "waz.tif")
