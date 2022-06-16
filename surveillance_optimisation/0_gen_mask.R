# Read in generic large template raster on same grid as all sims (i.e. host landscape)
templateRaster = raster::raster("../inputs/inputs_raw/host_landscape/CassavaMap/raw/CassavaMap_Prod_v1.tif")

# Read in poly of UGA
ugaPolysDf = sf::read_sf("../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg") |>
    dplyr::filter(GID_0=="UGA")

# Crop the template to the extent of the poly
templateRasterCrop = raster::crop(templateRaster, ugaPolysDf)

# Set all template values
templateRasterCrop[] = 0

# Create mask = update values covered by poly to 1
maskRaster = raster::mask(x=templateRasterCrop, mask=ugaPolysDf, updatevalue=1, inverse=TRUE)

# Save
raster::writeRaster(maskRaster, "./data/mask.tif")
