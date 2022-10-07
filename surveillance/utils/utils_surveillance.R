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
