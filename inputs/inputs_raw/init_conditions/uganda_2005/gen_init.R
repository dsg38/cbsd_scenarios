# ----------------------------------------
# This is how to convert from absolute number of inf fields to proportion of host that's inf
# ----------------------------------------

# Abs number of field suveys that are positive
numPosSurveysRaster = raster::raster("../../survey_rasters/cassava_data-2022_02_09/cbsd_positive/2005_raster_positive.tif")

# Normalised host raster
hostRaster = raster::raster("../../host_landscape/CassavaMap-cassava_data-2022_02_09/host.tif")

# ----------------------------------------

# The max number of hosts in the model is 1000. So a 1 in the normalised host raster is equiv of 1000 fields
singleFieldValue = 1/1000

# How many normalised fields are postive? Multiply absolute number by value of single field. i.e. equiv divide by 1000
numPosSurveysRasterNorm = numPosSurveysRaster * singleFieldValue

# What proportion of the host raster is infected? e.g. 300 infected fields out of 500 host = 0.3 / 0.5 = 0.6
infRaster =  numPosSurveysRasterNorm / hostRaster

# Set all NAs to zero
infRaster[is.na(infRaster)] = 0

# Calc sus raster
susRaster = 1 - infRaster

# Generate empty removed raster
remRaster = infRaster * 0

outDir = "./"
infRasterPath = file.path(outDir, "inf_raster.tif")
susRasterPath = file.path(outDir, "sus_raster.tif")
remRasterPath = file.path(outDir, "rem_raster.tif")

raster::writeRaster(infRaster, infRasterPath, overwrite=T)
raster::writeRaster(susRaster, susRasterPath, overwrite=T)
raster::writeRaster(remRaster, remRasterPath, overwrite=T)
