rasterOld = raster::raster("./2021_03_18_nigeria_region/inputs/vector.asc")
rasterNew = raster::raster("./2022_02_17_nigeria_region/inputs/vector.asc")

raster::plot(rasterOld, main="old")
raster::plot(rasterNew, main="new")

raster::cellStats(rasterOld, stat='sum', asSample=FALSE, na.rm=TRUE)
raster::cellStats(rasterNew, stat='sum', asSample=FALSE, na.rm=TRUE)

oldDiff = rasterOld[rasterOld != rasterNew]
newDiff = rasterNew[rasterOld != rasterNew]

diffValsDf = data.frame(
    oldVal = oldDiff,
    newVal = newDiff
)
