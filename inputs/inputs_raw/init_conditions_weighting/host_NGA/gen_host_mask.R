hostRaster = raster::raster("../../host_landscape/CassavaMap-cassava_data-2022_02_09/host.tif")
hostRaster[is.na(hostRaster)] = 0

# Country polys
ngaDf = sf::read_sf("../../../process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg") |>
    dplyr::filter(GID_0 == "NGA")

x = raster::mask(hostRaster, ngaDf, updatevalue=0)

raster::writeRaster(x, "./init_weighting.tif")
