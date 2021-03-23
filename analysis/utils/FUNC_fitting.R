options(stringsAsFactors = F)

# Inf prop
passInfPropFun = function(bigDf, polyName, polyTol){
  
  results = list()
  results[['surveyBool']] = FALSE
  results[['passKeys']] = NULL
  
  polyDf = bigDf[bigDf$polyName == polyName,]
  
  if(!nrow(polyDf) == 0){
    
    results[['surveyBool']] = TRUE
    
    dropKeys = unique(polyDf[abs(polyDf$targetDiff)>polyTol, "simKey"])
    
    allPolyKeys = unique(polyDf$simKey)
    passKeysBool = !(allPolyKeys %in% dropKeys)
    passKeys = allPolyKeys[passKeysBool]
    
    results[['passKeys']] = passKeys
    
  }
  
  return(results)
  
}

calcInfPropFun = function(bigDf, configMaskDf){
  
  yearResultsList = list()
  
  for(iRow in seq_len(nrow(configMaskDf))){
    
    thisConfigRow = configMaskDf[iRow,]
    
    yearStr = as.character(thisConfigRow$surveyDataYear)
    
    if(!(yearStr %in% names(yearResultsList))){
      yearResultsList[[yearStr]] = list()
    }
    
    thisPolyName = paste0(thisConfigRow$surveyDataYear, "_", thisConfigRow$mask)
    
    thisResults = passInfPropFun(bigDf, thisPolyName, thisConfigRow$tol)
    
    polyTolName = paste0(thisPolyName, "_", thisConfigRow$tol)
    
    yearResultsList[[yearStr]][[polyTolName]] = thisResults
    
  }
  
  return(yearResultsList)
}


# Calc grid
passGridFun = function(gridDf, configGridDf){
  
  gridPassList = list()
  for(iRow in seq_len(nrow(configGridDf))){
    
    thisConfigGridRow = configGridDf[iRow,]

    zeroPadTol =  sprintf("%.2f", thisConfigGridRow$gridTol)
    gridTolStr = gsub("\\.", "_", zeroPadTol)
    
    gridKey = paste0("grid_", thisConfigGridRow$gridMaxSurveyYear, "_", thisConfigGridRow$gridOffset, "_tol_", gridTolStr)
        
    gridDfSubset = gridDf[gridDf$maxYear==thisConfigGridRow$gridMaxSurveyYear & gridDf$offsetVal==thisConfigGridRow$gridOffset,]
    gridTol = thisConfigGridRow$gridTol
    gridPassKeys = gridDfSubset$simKeys[gridDfSubset$passProp>=gridTol]
    
    gridPassList[[gridKey]] = gridPassKeys
    
  }
  
  return(gridPassList)
  
}


# Calc yearly stats
calcYearlyStats = function(configMaskDf, yearResultsList, maskKey, gridKey, gridPassList){
  
  gridPassKeys = gridPassList[[gridKey]]

  cumYearList = list()
  yearSummaryList = list()
  yearsOrdered = sort(unique(configMaskDf$surveyDataYear))
  for(thisYear in yearsOrdered){
    
    thisYearStr = as.character(thisYear)
    
    maskNames = names(yearResultsList[[thisYearStr]])
    
    appliedMasks = c()
    for(thisMask in maskNames){
      
      if(yearResultsList[[thisYearStr]][[thisMask]][["surveyBool"]] == TRUE){
        cumYearList[[thisMask]] = yearResultsList[[thisYearStr]][[thisMask]][["passKeys"]]
        appliedMasks = c(appliedMasks, thisMask)
      }
      
    }
    
    passKeysCum = Reduce(intersect, cumYearList)
    passKeysCumGrid = intersect(passKeysCum, gridPassKeys)

    thisRow = data.frame(
      surveyDataYear=thisYear,
      numPass=length(passKeysCum),
      numPassGrid=length(passKeysCumGrid),
      maskKey=maskKey,
      masks=paste(appliedMasks, collapse = "|"),
      gridKey=gridKey
    )
    
    yearSummaryList[[thisYearStr]] = thisRow
  }
  
  yearSummaryDf = bind_rows(yearSummaryList)

  resultsList = list()
  resultsList[["yearSummaryDf"]] = yearSummaryDf
  resultsList[["passKeysAll"]] = passKeysCumGrid
  
  return(resultsList)

}

# Plot pass rate
plotPassRate = function(yearSummaryDf, outPath){

  p = ggplot(yearSummaryDf, aes(surveyDataYear)) +
    geom_line(aes(y = numPass, colour = "infProp")) +
    geom_line(aes(y = numPassGrid, colour = "infProp + grid"))

  suppressMessages(ggsave(outPath, plot = p))
}

# Plot infProp graph
genInfPropGraph = function(bigDfSubset, targetDf, title, outPath){

  bigDfSubset$surveyDataYear = as.numeric(bigDfSubset$surveyDataYear)
  bigDfSubset$infProp = as.numeric(bigDfSubset$infProp)
  # bigDfSubset$infProp = as.numeric(bigDfSubset$infProp)



  p = ggplot(data=bigDfSubset, aes(x=surveyDataYear, y=infProp)) + 
    geom_fan(intervals = seq(0,1,0.2)) +
    scale_fill_gradient(low="#5D5DF8", high="#C1C1EF") +
    ylim(0,1)+
    geom_line(data=targetDf, aes(x=surveyDataYear, y=targetVal), color="red") +
    geom_point(data=targetDf, aes(x=surveyDataYear, y=targetVal), color="red", fill="red") +
    ggtitle(title) +
    geom_point(data=targetDf, aes(x=surveyDataYear, y=tolMax), color="green", shape=25, fill="green") +
    geom_point(data=targetDf, aes(x=surveyDataYear, y=tolMin), color="green", shape=24, fill="green")
  
  # print(p)
  suppressMessages(ggsave(outPath, plot=p))
  
}

plotInfPropSinglePoly = function(bigDf, configMaskDf, passKeysAll, polyStr, thisFitKey, resultsDir){
  
  polyDf = bigDf[bigDf$polySuffix == polyStr,]
  polyPassDf = polyDf[polyDf$simKey %in% passKeysAll,]
  
  targetDfRaw = polyPassDf[polyPassDf$simKey==passKeysAll[1],]
  
  configPolyDf = configMaskDf[configMaskDf$mask==polyStr,]
  
  targetDfList = list()
  for(iRow in seq_len(nrow(configPolyDf))){
    
    configRow = configPolyDf[iRow,]
    
    surveyDataYear = configRow$surveyDataYear
    targetRow = targetDfRaw[targetDfRaw$surveyDataYear==surveyDataYear,]
    
    if(nrow(targetRow)>1){
      stop("targetRowEmpty")
    }
    else if(nrow(targetRow)==1){
      
      targetVal = targetRow$targetVal
      
      tolMin = targetVal - configRow$tol
      if(tolMin<0){
        tolMin = 0
      }
      
      tolMax = targetVal + configRow$tol
      if(tolMax>1){
        tolMax=1
      }
      
      outRow = data.frame(
        surveyDataYear=surveyDataYear,
        targetVal=targetVal,
        tolMin=tolMin,
        tolMax=tolMax
      )
      
      targetDfList[[as.character(iRow)]] = outRow
      
    }
    
  }
  
  targetDf = bind_rows(targetDfList)
  
  allTitle = paste0(thisFitKey, " - ", polyStr, " - all")
  allOutPath = file.path(resultsDir, paste0(polyStr, "_all.png"))
  genInfPropGraph(
    bigDfSubset = polyDf,
    targetDf = targetDf,
    title = allTitle,
    outPath = allOutPath
  )
  
  dropTitle = paste0(thisFitKey, " - ", polyStr, " - drop")
  dropOutPath = file.path(resultsDir, paste0(polyStr, "_drop.png"))
  genInfPropGraph(
    bigDfSubset = polyPassDf,
    targetDf = targetDf,
    title = dropTitle,
    outPath = dropOutPath
  )
  
}

plotInfPropAllPoly = function(bigDf, configMaskDf, passKeysAll, thisFitKey, resultsDir){

  if(length(passKeysAll)==0){
    return()
  }
  
  allPolyStr = unique(configMaskDf$mask)
  
  for(polyStr in allPolyStr){
    
    plotInfPropSinglePoly(bigDf, configMaskDf, passKeysAll, polyStr, thisFitKey, resultsDir)
    
  }
  
}
