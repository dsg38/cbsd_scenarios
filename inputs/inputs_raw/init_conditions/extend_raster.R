hostRaster = raster::raster("../host_landscape/default/host.tif")
infRaster = raster::raster("nigeria_direct_single_lagos/L_0_INFECTIOUS.txt")

infRasterBig = raster::extend(infRaster, raster::extent(hostRaster), value=0)

susRasterBig = 1 - infRasterBig

raster::writeRaster(infRasterBig, "nigeria_direct_single_lagos/inf_raster.tif")
raster::writeRaster(susRasterBig, "nigeria_direct_single_lagos/sus_raster.tif")