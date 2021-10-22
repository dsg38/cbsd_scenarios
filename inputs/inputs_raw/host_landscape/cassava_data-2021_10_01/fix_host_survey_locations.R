fixHost = function(hostRasterPath, surveyRasterDir, singleFieldVal, outPath){
  
  totalRasterPaths = list.files(path=surveyRasterDir, pattern="total", full.names = T)
  
  for(iRaster in seq_len(length(totalRasterPaths))){
    
    thisRasterPath = totalRasterPaths[iRaster]
    print(thisRasterPath)
    
    thisRaster = raster::raster(thisRasterPath)
    
    if(iRaster == 1){
      
      totalRaster = thisRaster
      
    }else{
      
      thisRasterBiggerLoc = thisRaster > totalRaster
      
      totalRaster[thisRasterBiggerLoc] = thisRaster[thisRasterBiggerLoc]
    }
    
  }
  
  
  hostRaster = raster::raster(hostRasterPath)
  hostRaster[is.na(hostRaster)] = 0
  
  minAllowedRaster = totalRaster * singleFieldVal
  
  whichToIncreaseRaster = hostRaster<minAllowedRaster
  
  outRaster = hostRaster
  outRaster[whichToIncreaseRaster] = minAllowedRaster[whichToIncreaseRaster]
  
  raster::writeRaster(outRaster, outPath, overwrite=T)
  
}

hostRasterPath = "../default/host.tif"
surveyRasterDir = "../../survey_rasters/cassava_data-2021_10_01/"
singleFieldVal = 1/1000
outPath = "./host.tif"

fixHost(
    hostRasterPath=hostRasterPath,
    surveyRasterDir=surveyRasterDir,
    singleFieldVal=singleFieldVal,
    outPath=outPath
)
