topDir = "./"
gridDfPaths = sort(list.files(topDir, "_grid_.*csv", full.names = T))

cutoff = 2010

summaryDf = data.frame()
for(thisGridDfPath in gridDfPaths){
    
    print(thisGridDfPath)

    thisGridName = gsub(".csv", "", basename(thisGridDfPath))

    thisGridDf = read.csv(thisGridDfPath)
    
    thisGridDfPreCutoff = thisGridDf[thisGridDf$year<=cutoff,]

    nonZeroBool = thisGridDf$propPos>0

    firstInfYear = NA
    leftDataBool = FALSE
    rightDataBool = FALSE
    
    if(any(nonZeroBool)){
        firstInfYear = min(thisGridDf[nonZeroBool, "year"])
        
        infYearMinus1 = firstInfYear - 1
        if(infYearMinus1 %in% thisGridDfPreCutoff$year){
            leftDataBool = TRUE
        }
        
        infYearPlus1 = firstInfYear + 1
        if(infYearPlus1 %in% thisGridDfPreCutoff$year){
            rightDataBool = TRUE
        }
    }
    
    bothDataBool = leftDataBool & rightDataBool
    
    eitherOrBothDataBool = leftDataBool | rightDataBool

    oneDataBool = eitherOrBothDataBool & !bothDataBool
    
    neighbouring_data_cat = NA
    if(bothDataBool){
        neighbouring_data_cat = "both"
    }else if(oneDataBool)(
        neighbouring_data_cat = "one"
    )else{
        neighbouring_data_cat = "none"
    }

    thisRow=data.frame(
        polySuffix=thisGridName,
        firstInfYear=firstInfYear,
        firstSurveyYear=min(thisGridDf$year),
        leftDataBool=leftDataBool,
        rightDataBool=rightDataBool,
        oneDataBool=oneDataBool,
        bothDataBool=bothDataBool,
        neighbouring_data_cat=neighbouring_data_cat
    )

    summaryDf = rbind(summaryDf, thisRow)
}

outPath = file.path(topDir, "grid_arrival_year.csv")
write.csv(summaryDf, outPath, row.names = F)
