extractManagementDf = function(
    thisManagementDf, 
    thisManagementPath,
    thisScenario,
    thisBatch, 
    thisJob
    ){

    box::use(utils[...])
    
    thisDir = dirname(thisManagementPath)
    thisManagementFilename = basename(thisManagementPath)
    
    splitFilename = strsplit(thisManagementFilename, "_")[[1]]
    
    thisSimYearStr = splitFilename[6]
    thisSimYear = as.numeric(gsub(".txt", "", thisSimYearStr))
    
    thisJobSim = as.numeric(splitFilename[2])
        
    thisManagementDfOut = cbind(
        scenario=thisScenario,
        batch=thisBatch,
        job=thisJob,
        jobSim=thisJobSim,
        simYear=thisSimYear,
        thisManagementDf
    )
    
    # Gen params
    paramsDfPath = file.path(thisDir, paste0("O_", thisJobSim, "_ParameterDistribution_0_Log.txt"))
    paramsDf = read.csv(paramsDfPath, sep="")
    
    thisManagementDfOut = cbind(thisManagementDfOut, paramsDf)
    
    return(thisManagementDfOut)
    
}

#' @export
aggregateManagementResults = function(simDir, stackedPathOut){

    box::use(utils[...])
    
    dir.create(dirname(stackedPathOut), showWarnings = F, recursive = T)

    jobDirs = list.files(simDir, "job*", full.names = T)[1:10]

    thisBatch = basename(simDir)

    thisScenario = basename(dirname(simDir))

    stackedManagementList = list()

    jobCount = 0
    numJobs = length(jobDirs)
    for(thisJobDir in jobDirs){
        
        print(paste0("Progress: ", jobCount/numJobs * 100, "%"))
        
        thisJob = basename(thisJobDir)
        print(thisJobDir)
        managementPaths = list.files(thisJobDir, pattern="O_.*_Management_SurveyResults_Time_.*.000000.txt", full.names = T, recursive = T)
        
        for(thisManagementPath in managementPaths){
            
            thisFilesize = file.size(thisManagementPath)
            if(!is.na(thisFilesize)){
                if(thisFilesize>0){

                    thisManagementDf = read.csv(thisManagementPath, sep="\t")

                    if(nrow(thisManagementDf)>0){

                        thisManagementDfOut = extractManagementDf(
                            thisManagementDf=thisManagementDf,
                            thisManagementPath=thisManagementPath,
                            thisScenario=thisScenario,
                            thisBatch=thisBatch,
                            thisJob=thisJob
                        )
                        stackedManagementList[[thisManagementPath]] = thisManagementDfOut

                    }
                }
            }
            else{
                print(thisManagementPath)
            }
            
        }
        
        jobCount = jobCount + 1
        
    }

    stackedManagementDf = dplyr::bind_rows(stackedManagementList)

    dir.create(dirname(stackedPathOut), showWarnings = FALSE, recursive = TRUE)

    saveRDS(stackedManagementDf, stackedPathOut)

}

#' @export
extractPolygonStats = function(
    stackedDfPath, 
    surveyMappingPath, 
    indexDir
    ){

    box::use(utils[...])

    stackedDfRaw = readRDS(stackedDfPath)
    aggLocKey = paste0(stackedDfRaw$X, "_", stackedDfRaw$Y)
    aggSimKey = paste(stackedDfRaw$scenario, stackedDfRaw$batch, stackedDfRaw$job, stackedDfRaw$jobSim, sep="-")
    stackedDf = cbind(stackedDfRaw, locKey=aggLocKey, simKey=aggSimKey)

    surveyMapping = rjson::fromJSON(file=surveyMappingPath)

    outCols = c(
        "scenario",
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
        
        nSurveyedAll = stats::aggregate(thisAggSubsetDf$NHostsSurveyed, by=list(simKey=thisAggSubsetDf$simKey), FUN=sum)
        nPosAll = stats::aggregate(thisAggSubsetDf$NHostsSurveyDetections, by=list(simKey=thisAggSubsetDf$simKey), FUN=sum)
        
        thisMergedDf = dplyr::left_join(nSurveyedAll, nPosAll, by="simKey")
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

    mergedDf = dplyr::bind_rows(mergedDfList)

    # -----------------------------------

    allAggKeepCols = stackedDf[,outCols]
    uniqueAggDf = dplyr::distinct(allAggKeepCols)

    outDf = dplyr::full_join(mergedDf, uniqueAggDf, by=c("simKey", "simYear"))

    outDfDrop = outDf[!is.na(outDf$polyName),]

    return(outDfDrop)

}


#' @export
dropIncompleteSimsSimSurvey = function(
    resDf, 
    indexDir
    ){

    box::use(utils[...])

    # Parse expected survey years for each poly
    indexPaths = list.files(indexDir, recursive = TRUE, full.names = TRUE)

    polyYearList = list()
    for(thisIndexPath in indexPaths){
        
        thisIndexDf = read.csv(thisIndexPath)    
        
        if(nrow(thisIndexDf) > 0){
            splitName = strsplit(tools::file_path_sans_ext(basename(thisIndexPath)), "_")[[1]]
            
            surveyYear = as.numeric(splitName[[1]])
            polySuffix = paste0(splitName[2:length(splitName)], collapse = "_")
            
            polyYearList[[polySuffix]] = c(polyYearList[[polySuffix]], surveyYear)
            
        }
        
    }

    # --------------------------------------------------------------------------

    brokenSimsVec = c()
    fullSims = c()
    for(thisSimKey in unique(resDf$simKey)){
        
        for(thisPolySuffix in names(polyYearList)){
            
            thisDf = resDf[resDf$simKey==thisSimKey&resDf$polySuffix==thisPolySuffix,]
            
            targetYears = polyYearList[[thisPolySuffix]]
            
            passAll = all(targetYears %in% unique(thisDf$surveyDataYear))
            
            if(passAll){
                
                fullSims = c(fullSims, thisSimKey)
                
            }else{
                
                brokenSimsVec = c(brokenSimsVec, thisSimKey)
                
            }
            
        }
        
    }

    brokenSims = unique(brokenSimsVec)

    print(paste0("Dropping: ", length(brokenSims)))

    fixedDf = resDf[resDf$simKey%in%fullSims,]

    return(fixedDf)

}


#' @export
appendSurveyDataTargetData = function(
    surveyDf,
    surveyPolyStatsDir
){

    box::use(utils[...])

    statsPaths = list.files(surveyPolyStatsDir, "mask", full.names = T)

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

    return(outDf)

}

#' @export
parseLaunchScript = function(launchScriptPath){

    box::use(utils[...])
    
    lines = readLines(launchScriptPath)
    
    for(line in lines){
        if(grepl("-o ", line)){
            outputDirLine = line
        }
        
        if(grepl("--landscapefolder", line)){
            inputsDirLine = line
        }
        
        if(grepl("--parametersfile", line)){
            paramsFileLine = line
        }
    }
    
    stopifnot(exists("outputDirLine"), exists("inputsDirLine"), exists("paramsFileLine"))
    
    outputDir = strsplit(outputDirLine, "\"")[[1]][[2]]
    
    outputDirParts = strsplit(outputDir, "/")[[1]]
    
    batch = dplyr::nth(outputDirParts, -1)
    scenario = dplyr::nth(outputDirParts, -2)
    
    # -----------------------------------
    
    inputsDir = strsplit(inputsDirLine, "\"")[[1]][[2]]
    inputsDirParts = strsplit(inputsDir, "/")[[1]]
    
    inputsDirPartsHere = c()
    for(i in -4:-2){
        inputsDirPartsHere = c(inputsDirPartsHere, dplyr::nth(inputsDirParts, i))
    }
    
    inputsDirHere = here::here(paste0(inputsDirPartsHere, collapse = "/"))
    
    # -----------------------------------
    paramsFilename = strsplit(paramsFileLine, "\"")[[1]][[2]]
    paramsDfPath = file.path(dirname(launchScriptPath), paramsFilename)
    paramsDf = read.table(paramsDfPath, header=TRUE)
    
    # -----------------------------------
    outList = list(
        batch=batch,
        scenario=scenario,
        inputsDir=inputsDirHere,
        paramsDf=paramsDf
    )
    
    return(outList)
    
}

#' @export
parseScenarioConfig = function(
    inputsDir
){
    
    # Parse config / work out polys
    scenarioConfigPath = here::here(inputsDir, "config.json")
    
    scenarioConfig = rjson::fromJSON(file=scenarioConfigPath)
    
    surveyBool = "processSurvey" %in% names(scenarioConfig)
    
    surveyPolyStatsDir = NULL
    if(surveyBool){

        polyDfName = scenarioConfig[["processSurvey"]][["polyDfName"]]

        polyDir = paste0(strsplit(polyDfName, "_")[[1]][1:2], collapse = "_")
        
        surveyPolyStatsDir = here::here("inputs/inputs_raw/survey_rasters", scenarioConfig[["processSurvey"]][["surveyDir"]], "poly_stats", polyDir)
        
    }
    
    outList = list(
        surveyBool=surveyBool,
        surveyPolyStatsDir=surveyPolyStatsDir
    )
    
    return(outList)
}

#' @export
dropSimsNotFinished = function(
    resultsDf,
    paramsDf,
    progressDfPath
){

    box::use(utils[...])

    progressDf = read.csv(progressDfPath)
    
    endSimTime = paramsDf$SimulationStartTime + paramsDf$SimulationLength
    
    notDoneDf = progressDf[progressDf$dpcLastSimTime!=endSimTime,]
    
    resultsDfOut = resultsDf[!(resultsDf$job %in% notDoneDf$jobName),]
    
    return(resultsDfOut)
    
}
