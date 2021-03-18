library(dplyr)

lat = -7.15
lng = 38.78

radiusKm = 10

kmInDecimalDegrees = 111

# ----------------------------------------

hostRasterPath = "inputs_raw/host_landscape/CassavaMap_Prod_v1_NORMALISED_FIXED.tif"

hostRaster = raster::raster(hostRasterPath)

extent = c(xmin=36, xmax=40, ymin=-10, ymax=-5)

hostRaster = raster::crop(hostRaster, extent)

hostRasterCrs = raster::projectRaster(hostRaster, crs=3035)

# raster::crs(hostRaster)
# raster::crs(hostRasterCrs)

# Convert to df
pointsDfRaw = data.frame(lat=lat, lng=lng)

# Convert df to spatial + coord system that can buffer in m
pointsDf = sf::st_as_sf(pointsDfRaw, coords = c("lng", "lat"), crs = my::getWgsCode()) %>% sf::st_transform(3035)

# Convert to circles
circlesDf = sf::st_buffer(pointsDf, dist = radiusKm * 1000)

# Mask raster layer
x = raster::mask(hostRasterCrs, circlesDf, updatevalue=0)

raster::plot(x)
plot(circlesDf, add=T)

raster::writeRaster(x, "out.tif", overwrite=TRUE)

# africaPolys = my::loadPolysAfrica()
# plot(africaPolys, max.plot = 1)
# 
# plot(circlesDf)
# plot(africaPolys, add=T)


# Is there any host within radiusKm of each point?
