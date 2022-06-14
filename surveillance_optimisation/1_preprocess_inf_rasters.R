# Read in mask
maskRaster = raster::raster("./mask.tif")

# Define paths to target rasters
infRasterPaths = list.files(
    path="../simulations/sim_output/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/",
    pattern="O_0_L_0_INFECTIOUS_2009.000000.tif",
    recursive = TRUE,
    full.names = TRUE
)

# Read in and crop
infRasterStack = raster::stack(infRasterPaths)
raster::crs(infRasterStack) = "EPSG:4326"

infRasterBrickCrop = raster::crop(infRasterStack, maskRaster)

# Use mask to set all values outside of mask layer to 0
infRasterBrickMask = infRasterBrickCrop
infRasterBrickMask[maskRaster==0] = 0

# Set all NA to zero
infRasterBrickMask[is.na(infRasterBrickMask)] = 0

# mapview::mapview(maskRaster)
# mapview::mapview(infRasterBrickCrop[[1]])
# mapview::mapview(infRasterBrickMask[[1]])

# Save
raster::writeRaster(infRasterBrickMask, "brick.tif", overwrite=TRUE)
