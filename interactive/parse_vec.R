v = raster::raster("../inputs/inputs_raw/vector/default/vector.tif")
raster::crs(v) = "EPSG:4326"

# Crop to land
africaPolysDf = sf::read_sf("../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg")
vMasked = raster::mask(v, africaPolysDf)

# Save
raster::writeRaster(vMasked, "data/vector.tif")
