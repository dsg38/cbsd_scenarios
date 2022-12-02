infBrickPath = "../../inputs/inf_rasters_processed/di_NGA_year_1/outputs/brick_STORE.tif"

infBrick = raster::brick(infBrickPath)


x = infBrick[[1:250]]

raster::writeRaster(x, "../../inputs/inf_rasters_processed/di_NGA_year_1/outputs/brick.tif")
