library(tictoc)
args = commandArgs(trailingOnly = TRUE)

tic()

configPath = args[[1]]
# configPath = "./cc_CMR_year_0/config.json"

# Read config json / build paths
configList = rjson::fromJSON(file=configPath)

infRasterDir = file.path("../inf_rasters", configList$inf_rasters, "raw")
maskRasterPath = file.path("../masks", configList$mask, "mask.tif")

outDir = file.path(dirname(configPath), "outputs")
dir.create(outDir, recursive = TRUE, showWarnings = FALSE)

# Read in mask
maskRaster = raster::raster(maskRasterPath)

# Define paths to target rasters
infRasterPaths = list.files(
    path=infRasterDir,
    pattern="*.tif",
    recursive = TRUE,
    full.names = TRUE
)

# Process each raster individually and glue into brick
i = 0
infRasterProcessedList = list()
for(infRasterPath in infRasterPaths){

    print(i)

    # Read in raster
    thisRaster = raster::raster(infRasterPath)
    raster::crs(thisRaster) = "EPSG:4326"

    # Crop
    thisRasterCrop = raster::crop(thisRaster, maskRaster)

    # Use mask to set all values where mask layer==0 to 0 (i.e. non target areas set to zero)
    thisRasterCrop[maskRaster==0] = 0

    # Set all NA to zero
    thisRasterCrop[is.na(thisRasterCrop)] = 0

    # Add to list
    infRasterProcessedList[[infRasterPath]] = thisRasterCrop

    i = i + 1

}

infRasterBrickMask = raster::brick(infRasterProcessedList)

# Save brick
brickOutPath = file.path(outDir, "brick.tif")

raster::writeRaster(infRasterBrickMask, brickOutPath, overwrite=TRUE)

# --------------------------------
# Generate sum raster csv and tif

print("Num rasters:")
print(raster::nlayers(infRasterBrickMask))

sumRaster = infRasterBrickMask[[1]]
for(i in 2:raster::nlayers(infRasterBrickMask)){
    print(i)
    sumRaster = sumRaster + infRasterBrickMask[[i]]
}

sumRasterMask = sumRaster * maskRaster
sumRasterMask[sumRasterMask==0] = NA

sumRasterMaskPointsDf = as.data.frame(raster::rasterToPoints(sumRasterMask))

write.csv(sumRasterMaskPointsDf, file.path(outDir, "sumRasterMaskPointsDf.csv"), row.names=FALSE)

# Save sum raster
raster::writeRaster(sumRasterMask, file.path(outDir, "sumRasterMask.tif"), overwrite=TRUE)

toc()
