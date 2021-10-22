# Use raw sim output raster
infRasterEndemic = raster::raster("../../../../simulations/sim_output/2021_10_15_endemic_seed/2021_10_15_batch_0/job91/output/runfolder0/O_0_L_0_INFECTIOUS_10.000000.tif")

infRasterUga = raster::raster("../uganda_2005/inf_raster.tif")

# -----------------------------------------------------------------

# Extend to full host landscape size
infRasterEndemicBig = raster::extend(infRasterEndemic, raster::extent(infRasterUga), value=0)

# Add endemic inf to 
infRaster = infRasterUga + infRasterEndemicBig

# Drop any NAs
infRaster[is.na(infRaster)] = 0

# Build sus
susRaster = 1 - infRaster

# Build rem
remRaster = susRaster
remRaster[] = 0

# Save
raster::writeRaster(infRaster, "./inf_raster.tif")
raster::writeRaster(susRaster, "./sus_raster.tif")
raster::writeRaster(remRaster, "./rem_raster.tif")
