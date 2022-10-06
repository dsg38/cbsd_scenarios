library(tictoc)
args = commandArgs(trailingOnly = TRUE)

tic()

configPath = args[[1]]


# Read in mask
maskRaster = raster::raster("./data/mask.tif")

# Define paths to target rasters
infRasterPaths = list.files(
    path="./inf_rasters/raw/",
    pattern=".*-0.tif",
    recursive = TRUE,
    full.names = TRUE
)

cropList = list()
i = 0
for(infRasterPath in infRasterPaths){

    print(i)

    thisRaster = raster::raster(infRasterPath)
    raster::crs(thisRaster) = "EPSG:4326"
    thisRasterCrop = raster::crop(thisRaster, maskRaster)

    thisRasterCrop[maskRaster==0] = 0
    thisRasterCrop[is.na(thisRasterCrop)] = 0


    cropList[[infRasterPath]] = thisRasterCrop

    i = i + 1

}

print("STACKIGN")
infRasterBrickMask = raster::stack(cropList)


# Read in and crop
# infRasterStack = raster::stack(infRasterPaths)
# raster::crs(infRasterStack) = "EPSG:4326"

# infRasterBrickCrop = raster::crop(infRasterStack, maskRaster)

# Use mask to set all values outside of mask layer to 0
# infRasterBrickMask = infRasterBrickCrop
# infRasterBrickMask[maskRaster==0] = 0

# # Set all NA to zero
# infRasterBrickMask[is.na(infRasterBrickMask)] = 0

# mapview::mapview(maskRaster)
# mapview::mapview(infRasterBrickCrop[[1]])
# mapview::mapview(infRasterBrickMask[[1]])

# Save
print("HEREEE")
raster::writeRaster(infRasterBrickMask, "./data/brick.tif", overwrite=TRUE)

# --------------------------------

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

write.csv(sumRasterMaskPointsDf, "./data/sumRasterMaskPointsDf.csv", row.names=FALSE)

# Save sum raster
raster::writeRaster(sumRasterMask, "./data/sumRasterMask.tif", overwrite=TRUE)

# mapview::mapview(sumRasterMask)

toc()
