
genSurveyRasters = function(surveyData, templateRasterPath, outDir){
  
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
    
    outPathTotal = file.path(outDir, paste0(thisYear, "_raster_total.tif"))
    raster::writeRaster(outRasterTotal, outPathTotal, overwrite=TRUE)
    
  }
  
}

surveyData = sf::read_sf("../../../../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.gpkg")
templateRasterPath = "../host_landscape/default/host.tif"
outDir = "./cassava_data-2022_02_09/"

genSurveyRasters(
    surveyData=surveyData,
    templateRasterPath=templateRasterPath,
    outDir=outDir
)
