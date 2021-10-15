library(raster)
library(gstat)
library(rworldmap)

surveyData = read.csv("../../../../cassava_data/data_merged/data/2021_10_01/cassava_data_minimal.csv") |>
    dplyr::rename(
        x=longitude,
        y=latitude,
        vector=adult_whitefly_mean
    )

outDir = "./cassava_data-2021_10_01"

templateRasterPath = "../host_landscape/default/host.tif"

# ------------------------------------------------------------------

dir.create(outDir, recursive=T, showWarnings = F)

cap_pre_idw = 100
cap_post_idw = 20
idw_param = 1
grid_res_reduction = 5

templateExtentRaster = raster(templateRasterPath)
templateExtent = extent(templateExtentRaster)
templateResolution = res(templateExtentRaster) * grid_res_reduction

templateRaster = raster(x=templateExtent, resolution=templateResolution)
templateSpatialPixels = as(templateRaster, "SpatialPixels")

surveyData = surveyData[!is.na(surveyData$vector),]
coordsDf = surveyData[,c("x", "y")]
coordinates(coordsDf) = ~x+y

# Cap values above a given mean
surveyData[surveyData$vector>cap_pre_idw, "vector"] = cap_pre_idw

# Gen IDW raster
idwOutput = idw(formula =  surveyData$vector~1, locations = coordsDf, newdata = templateSpatialPixels, idp=idw_param)
idwRaster = raster(idwOutput)

# Normalise
idwRaster[idwRaster > cap_post_idw] = cap_post_idw
normRaster = idwRaster / cap_post_idw

normRasterOutPath = file.path(outDir, "vector.tif")

# Crop and write out
writeRaster(normRaster, normRasterOutPath, overwrite=T)
