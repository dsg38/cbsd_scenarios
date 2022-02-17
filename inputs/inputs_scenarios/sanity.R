infRaster = raster::raster("./inputs/L_0_INFECTIOUS.txt")
susRaster = raster::raster("./inputs/L_0_SUSCEPTIBLE.txt")


infRaster[][infRaster[]>0]
susRaster[][infRaster[]>0]


susRaster[][susRaster[]<1]

hostRaster = raster::raster("./inputs/L_0_HOSTDENSITY.txt")

raster::cellStats(hostRaster, stat='max', asSample=FALSE)


x = raster::raster("../../../../cbsd_landscape_model/simulations/fitting/inputs/agg_inputs/L_0_HOSTDENSITY.txt")

raster::cellStats(x, stat='max', asSample=FALSE)
