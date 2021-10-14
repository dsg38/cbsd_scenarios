rasterA = raster::raster("./default/vector.tif")
rasterB = raster::raster("./cassava_data-2021_10_01/idw_raster_param_1_data_C.tif")

diffRaster = rasterB - rasterA
raster::plot(diffRaster)

# diffPropRaster = diffRaster / rasterA
# raster::plot(diffPropRaster)

# x = diffRaster[][diffRaster[] > 0]
# # hist(x)
# max(x)

# rev(sort(x))[1:10]

hist(rasterA[], xlim=c(0,1))
hist(rasterB[], xlim=c(0,1))
hist(diffRaster[], xlim=c(0,1))

# raster::writeRaster(diffRaster, filename = "waz.tif")
