library(raster)
library(gstat)
library(rworldmap)

# genVectorLayer = function(surveyData, outDir, dataset_letter, templateRasterPath){

surveyData = read.csv("../../../../cassava_data/data_merged/data/2021_10_01/cassava_data_minimal.csv") |>
    dplyr::rename(
        x=longitude,
        y=latitude,
        vector=adult_whitefly_mean
    )


outDir = "./cassava_data-2021_10_01"
dataset_letter = "C"
templateRasterPath = "./inputs/CassavaMap_Prod_v1.tif"

# ------------------------------------------------------------------

# surveyData = read.csv("../../../../cbsd_landscape_model/input_generation/surveillance_data/raw_data/survey_data_summary.csv")
# outDir = "./default_regen"
# dataset_letter = "C"
# templateRasterPath = "./inputs/CassavaMap_Prod_v1.tif"


# -------------------------------------------------------------------------------------------

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

normRasterOutPath = file.path(outDir, paste0("idw_raster_param_", idw_param, "_data_", dataset_letter, ".tif"))

# Crop and write out
writeRaster(normRaster, normRasterOutPath, overwrite=T)

countryPolys = getMap(resolution = "high")
ugaPoly = countryPolys[countryPolys@data$ADM0_A3=="UGA",]  

normRasterOutPathUga = file.path(outDir, paste0("idw_raster_param_", idw_param, "_data_", dataset_letter, "_UGA.tif"))
normRasterUga = crop(normRaster, ugaPoly)

writeRaster(normRasterUga, normRasterOutPathUga, overwrite=T)

# }
