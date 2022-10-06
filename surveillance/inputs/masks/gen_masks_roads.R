box::use(../../../inputs/utils)
args = commandArgs(trailingOnly = TRUE)

configPath = args[[1]]
# configPath = "./mask_roads_CMR_1000m_extent_CMR/config.json"

# Read config json
configList = rjson::fromJSON(file=configPath)

# Read in generic large template raster on same grid as all sims (i.e. host landscape)
templateRaster = raster::raster("../../../inputs/inputs_raw/host_landscape/CassavaMap/raw/CassavaMap_Prod_v1.tif")

# Get extent
cropExtent = utils$getExtentVecFromConfig(configList)

# Get roads file
roadsPolyDfPath = file.path("./data_roads/data/buffer/", paste0(configList$roads_country_vec, ".gpkg"))

stopifnot(file.exists(roadsPolyDfPath))

roadsPolyDf = sf::read_sf(roadsPolyDfPath)

# Crop the template to the extent of the poly
templateRasterCrop = raster::crop(templateRaster, cropExtent)

# Set all template values
templateRasterCrop[] = 0

# Create mask = update values covered by poly to 1
maskRaster = raster::mask(x=templateRasterCrop, mask=roadsPolyDf, updatevalue=1, inverse=TRUE)

# Save
outPath = file.path(dirname(configPath), "mask.tif")
raster::writeRaster(maskRaster, outPath)
