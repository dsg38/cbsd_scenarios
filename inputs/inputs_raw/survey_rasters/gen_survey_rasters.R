
genSurveyRasters = function(surveyData, templateRasterPath, rasterSuffix, outDir){
  
  templateRaster = raster::raster(templateRasterPath)
  templateRaster[] = 0
  
  dir.create(outDir, recursive=T, showWarnings = F)
  
  allYears = sort(unique(surveyData$year))
  
  for(thisYear in allYears){
    
    print(thisYear)
    
    thisYearDf = surveyData[surveyData$year==thisYear,]
    
    if(nrow(thisYearDf)>0){
      outRasterTotal = raster::rasterize(x=thisYearDf, y=templateRaster, field=1, fun="sum", background=0)
    } else {
      outRasterTotal = templateRaster
    }
    
    outPathTotal = file.path(outDir, paste0(thisYear, rasterSuffix))
    raster::writeRaster(outRasterTotal, outPathTotal, overwrite=TRUE)
    
  }
  
}

# All
# surveyData = sf::read_sf("../../../../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.gpkg")
# templateRasterPath = "../host_landscape/default/host.tif"
# rasterSuffix = "_raster_total.tif"
# outDir = "./cassava_data-2022_02_09/"

# Positives
surveyData = sf::read_sf("../../../../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.gpkg") |>
    dplyr::filter(cbsd_foliar_bool==TRUE)

templateRasterPath = "../host_landscape/CassavaMap/host.tif"
rasterSuffix = "_raster_positive.tif"
outDir = "./cassava_data-2022_02_09/cbsd_positive/"

genSurveyRasters(
    surveyData=surveyData,
    templateRasterPath=templateRasterPath,
    rasterSuffix=rasterSuffix,
    outDir=outDir
)
