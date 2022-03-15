# Use raw sim output raster
infRasterEndemic = raster::raster("../../../../simulations/sim_output/2022_03_02_endemic_seed/2022_03_02_batch_0/job64/output/runfolder0/O_0_L_0_INFECTIOUS_20.000000.tif")

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
remRaster = susRaster * 0

# Save
raster::writeRaster(infRaster, "./inf_raster.tif")
raster::writeRaster(susRaster, "./sus_raster.tif")
raster::writeRaster(remRaster, "./rem_raster.tif")
