options(stringsAsFactors = F)

appendTargetDataFunc = function(surveyDfPath, statisticDir, outPath) {

  surveyDf = readRDS(surveyDfPath)

  statsPaths = list.files(statisticDir, "mask", full.names = T)

  statsList = list()
  for(thisStatsPath in statsPaths){
    
    thisMask = gsub(".csv", "", basename(thisStatsPath))
    
    statsList[[thisMask]] = list()
    
    thisStatsDf = read.csv(thisStatsPath)
    for(iRow in seq_len(nrow(thisStatsDf))){
      
      thisYear = thisStatsDf[iRow,"year"]  
      thisInfProp = thisStatsDf[iRow,"propPos"]  
      
      statsList[[thisMask]][[as.character(thisYear)]] = thisInfProp
      
    }
    
  }

  numSurveyRows = nrow(surveyDf)
  targetVals = rep(NA, numSurveyRows)

  for(iRow in seq_len(numSurveyRows)){
    
    if(iRow%%10000==0){
      progressNum = round(iRow/numSurveyRows * 100, 2)
      print(paste0("Progress: ", progressNum, "%"))
    }
    
    surveyYear = as.character(surveyDf[iRow,"surveyDataYear"])
    targetMask = surveyDf[iRow,"polySuffix"]
    
    targetVal = statsList[[targetMask]][[surveyYear]]
    
    if(!is.null(targetVal)){
      targetVals[iRow] =  targetVal  
    }
    
  }

  targetDiff = surveyDf$infProp - targetVals

  outDf = cbind(
    surveyDf, 
    targetVal=targetVals, 
    targetDiff=targetDiff
  )

  saveRDS(outDf, outPath)

}
