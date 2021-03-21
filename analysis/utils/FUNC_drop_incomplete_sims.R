options(stringsAsFactors = F)

dropIncompleteSims = function(resPath, outPath, simYearMin, simYearMax){

  resDf = readRDS(resPath)

  totalPolySuffix = "raster_total"

  simYears = seq(simYearMin, simYearMax)

  simKeys = unique(resDf$simKey)

  brokenSims = c()
  fullSims = c()
  for(thisSimKey in simKeys){
    
    thisDf = resDf[resDf$simKey==thisSimKey&resDf$polySuffix==totalPolySuffix,]
    
    passAll = all(simYears %in% thisDf$simYear)
    
    if(passAll){
      
      fullSims = c(fullSims, thisSimKey)
      
    }else{
      
      brokenSims = c(brokenSims, thisSimKey)
    }
  }

  print(paste0("Dropping: ", length(brokenSims)))

  fixedDf = resDf[resDf$simKey%in%fullSims,]

  saveRDS(fixedDf, outPath)

}
