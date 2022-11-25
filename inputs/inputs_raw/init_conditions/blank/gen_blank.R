hostRaster = raster::raster("../../host_landscape/CassavaMap-cassava_data-2022_02_09/host.tif")

hostRaster[is.na(hostRaster)] = 0
hostRaster[hostRaster!=0] = 0

# Save as tifs
raster::writeRaster(hostRaster, "./inf_raster.tif")
raster::writeRaster(hostRaster, "./sus_raster.tif")
raster::writeRaster(hostRaster, "./rem_raster.tif")
