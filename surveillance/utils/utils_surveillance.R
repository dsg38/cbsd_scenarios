#' @export
genConfigs = function(
    configSweepPath
    ){

    configSweepList = rjson::fromJSON(file=configSweepPath)

    # Define output dir
    topDir = file.path(dirname(configSweepPath), "sweep")

    # Define fixed params
    inputsKey = configSweepList[["inputsKey"]]
    rewardRatio = configSweepList[["rewardRatio"]]
    niter = configSweepList[["niter"]]

    # Define sweep params
    numSurveysVec = configSweepList[["numSurveysVec"]]
    detectionProbVec = configSweepList[["detectionProbVec"]]

    initTempVec = configSweepList[["initTempVec"]]
    stepVec = signif(10**(c(configSweepList[["stepPowersVec"]])), 2)

    # Build configs
    i = 0

    for(numSurveys in numSurveysVec){

        for(detectionProb in detectionProbVec){

            for(step in stepVec){
                
                for(initTemp in initTempVec){
                    
                    print(i)
                    
                    thisDir = file.path(topDir, paste0("sweep_", i))
                    configPath = file.path(thisDir, "config.json")
                    
                    dir.create(thisDir, recursive = TRUE, showWarnings = FALSE)
                    
                    configList = list(
                        "inputsKey" = inputsKey,
                        "rewardRatio" = rewardRatio,
                        "niter" =  niter,

                        "numSurveys" = numSurveys,
                        "detectionProb" =  detectionProb,
                        "step" = step,
                        "initTemp" = initTemp
                    )
                    
                    # Save
                    configStr = jsonlite::toJSON(configList, auto_unbox = TRUE, pretty = TRUE)
                    
                    readr::write_lines(configStr, file=configPath)
                    
                    i = i + 1   
                    
                }
            
            }

        }

    }
    
}

#' @export
genSweepOptimalDf = function(configSweepPath){

    configSweepList = rjson::fromJSON(file=configSweepPath)

    # Define output dir
    topDir = file.path(dirname(configSweepPath), "sweep")

    # Define fixed params
    inputsKey = configSweepList[["inputsKey"]]
    rewardRatio = configSweepList[["rewardRatio"]]
    niter = configSweepList[["niter"]]

    # Define sweep params
    numSurveysVec = configSweepList[["numSurveysVec"]]
    detectionProbVec = configSweepList[["detectionProbVec"]]

    initTempVec = configSweepList[["initTempVec"]]
    stepVec = signif(10**(c(configSweepList[["stepPowersVec"]])), 2)

    # Build configs
    i = 0
    traceDfMaxList = list()
    optimalDfList = list()
    for(numSurveys in numSurveysVec){

        for(detectionProb in detectionProbVec){

            # For the hyperparm sweep for each numSurveys / detectionProb combo, pull out the best hyperparams
            traceDfMaxSubsetList = list()

            for(step in stepVec){
                
                for(initTemp in initTempVec){
                    
                    print(i)

                    thisDir = file.path(topDir, paste0("sweep_", i))
                    configPath = file.path(thisDir, "config.json")
                    configList = rjson::fromJSON(file=configPath)

                    configDf = data.frame(configList)

                    traceDfPath = file.path(thisDir, "outputs", "traceDf.rds")

                    traceDf = readRDS(traceDfPath) |>
                        dplyr::mutate(
                            sweep_i = i
                        )

                    # Extract max per scenario
                    traceDfMax = traceDf[traceDf$objective_func_val == max(traceDf$objective_func_val),]
                    
                    if(nrow(traceDfMax) > 1){
                        traceDfMax = traceDfMax[traceDfMax$iteration==max(traceDfMax$iteration),]
                    }
                    
                    traceDfMaxConfig = cbind(traceDfMax, configDf)
                    
                    traceDfMaxList[[traceDfPath]] = traceDfMaxConfig
                    traceDfMaxSubsetList[[traceDfPath]] = traceDfMaxConfig

                    i = i + 1   
                    
                }
            
            }

            # Find max of this param set
            traceDfMaxSubset = dplyr::bind_rows(traceDfMaxSubsetList)

            # Extract max per scenario
            paramDfMax = traceDfMaxSubset[traceDfMaxSubset$objective_func_val == max(traceDfMaxSubset$objective_func_val),]
            if(nrow(paramDfMax) > 1){
                stop("SAME PARAM VALS FOR BOTH!!")
            }
            
            optimalDfList[[as.character(i)]] = paramDfMax

        }

    }

    optimalDf = dplyr::bind_rows(optimalDfList)

    return(optimalDf)

}

#' @export
genSweepSurfacePlot = function(
    optimalDf,
    plotDir
){

    dir.create(plotDir, showWarnings = FALSE, recursive = TRUE)

    p = plotly::plot_ly() |> 
        plotly::add_trace(data = optimalDf,  x=~numSurveys, y=~detectionProb, z=~objective_func_val, type="mesh3d") |>
        plotly::add_trace(data = optimalDf, x=~numSurveys, y=~detectionProb, z=~objective_func_val, mode = "markers", type = "scatter3d", marker = list(size = 5, color = "red", symbol = 104))

    outPath = file.path(plotDir, "sweep_surface.html")
    htmlwidgets::saveWidget(p, outPath, selfcontained = T)

}

