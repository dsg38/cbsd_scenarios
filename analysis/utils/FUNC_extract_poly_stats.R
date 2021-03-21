options(stringsAsFactors = F)
library(rjson)
library(dplyr)




# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------

extractPolygonStats = function(stackedDfPath, surveyMappingPath, indexDir, summaryOutPath){

  dir.create(dirname(summaryOutPath), recursive=T, showWarnings=F)

  stackedDfRaw = readRDS(stackedDfPath)
  aggLocKey = paste0(stackedDfRaw$X, "_", stackedDfRaw$Y)
  aggSimKey = paste0(stackedDfRaw$batch, "_", stackedDfRaw$job, "_", stackedDfRaw$jobSim)
  stackedDf = cbind(stackedDfRaw, locKey=aggLocKey, simKey=aggSimKey)

  surveyMapping = fromJSON(file=surveyMappingPath)

  outCols = c(
    "batch",
    "job",
    "jobSim",
    "simYear",
    "simKey",
    "Kernel_0_Parameter",
    "Kernel_0_WithinCellProportion",
    "Rate_0_Sporulation"
  )

  simYears = unique(stackedDf$simYear)

  maskList = list()
  for(thisSimYear in simYears){

    print(thisSimYear)
    
    thisRasterName = surveyMapping[[as.character(thisSimYear)]]
    thisSurveyDataYear = gsub("_raster_total.asc", "", thisRasterName)
    thisYearMaskDfPaths = list.files(indexDir, thisSurveyDataYear, full.names = T)
    
    for(thisYearMaskDfPath in thisYearMaskDfPaths){

      polyName = gsub(".csv", "", basename(thisYearMaskDfPath))
      polySuffix = gsub(paste0(thisSurveyDataYear, "_"), "", polyName)
      
      thisIndexDfRaw = read.csv(thisYearMaskDfPath)
      
      if(nrow(thisIndexDfRaw) > 0){

        indexLocKey = paste0(thisIndexDfRaw$X, "_", thisIndexDfRaw$Y)
        thisIndexDf = cbind(thisIndexDfRaw, locKey=indexLocKey)
        
        maskList[[thisYearMaskDfPath]] = list()
        maskList[[thisYearMaskDfPath]][["df"]] = thisIndexDf
        maskList[[thisYearMaskDfPath]][["polyName"]] = polyName
        maskList[[thisYearMaskDfPath]][["polySuffix"]] = polySuffix
        maskList[[thisYearMaskDfPath]][["thisSimYear"]] = thisSimYear
        maskList[[thisYearMaskDfPath]][["thisSurveyDataYear"]] = thisSurveyDataYear

      }
    }
  }

  # --------------------

  mergedDfList = list()

  for(thisYearMaskDfPath in names(maskList)){
    
    print(thisYearMaskDfPath)
    
    thisYearMaskDf = maskList[[thisYearMaskDfPath]][["df"]]
    polyName = maskList[[thisYearMaskDfPath]][["polyName"]]
    polySuffix = maskList[[thisYearMaskDfPath]][["polySuffix"]]
    thisSimYear = maskList[[thisYearMaskDfPath]][["thisSimYear"]]
    thisSurveyDataYear = maskList[[thisYearMaskDfPath]][["thisSurveyDataYear"]]

    matchYear = stackedDf$simYear==thisSimYear
    matchMask = stackedDf$locKey%in%thisYearMaskDf$locKey
    
    thisAggSubsetDf = stackedDf[matchYear&matchMask,]

    # browser()
    
    nSurveyedAll = aggregate(thisAggSubsetDf$NHostsSurveyed, by=list(simKey=thisAggSubsetDf$simKey), FUN=sum)
    nPosAll = aggregate(thisAggSubsetDf$NHostsSurveyDetections, by=list(simKey=thisAggSubsetDf$simKey), FUN=sum)
    
    thisMergedDf = left_join(nSurveyedAll, nPosAll, by="simKey")
    colnames(thisMergedDf) = c("simKey", "nSurveyed", "nPos")
    
    thisMergedDf = cbind(
      thisMergedDf,
      infProp = thisMergedDf$nPos / thisMergedDf$nSurveyed,
      simYear=thisSimYear,
      polyName=polyName,
      polySuffix=polySuffix,
      surveyDataYear=thisSurveyDataYear
    )
    
    mergedDfList[[thisYearMaskDfPath]] = thisMergedDf

  }

  mergedDf = bind_rows(mergedDfList)

  # -----------------------------------

  allAggKeepCols = stackedDf[,outCols]
  uniqueAggDf = distinct(allAggKeepCols)

  outDf = full_join(mergedDf, uniqueAggDf, by=c("simKey", "simYear"))



  saveRDS(outDf, summaryOutPath)

}

