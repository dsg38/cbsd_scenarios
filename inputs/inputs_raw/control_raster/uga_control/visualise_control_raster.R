# x = raster::raster("./outputs/control_raster_TEMP.asc")
x = raster::raster("../../../inputs_scenarios/2022_03_15_cross_continental_endemic/inputs/control_raster_TEMP.asc")
raster::crs(x) = "EPSG:4326"
mapview::mapview(x)
