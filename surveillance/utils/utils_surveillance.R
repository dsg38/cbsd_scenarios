#' @export
genConfigs = function(
    configSweepPath
    ){

    configSweepList = rjson::fromJSON(file=configSweepPath)

    # Define output dir
    topDir = file.path(dirname(configSweepPath), "sweep")

    # Define fixed params
    inputsKey = configSweepList[["inputsKey"]]
    numSurveys = configSweepList[["numSurveys"]]
    rewardRatio = configSweepList[["rewardRatio"]]
    detectionProb = configSweepList[["detectionProb"]]
    niter = configSweepList[["niter"]]

    # Define sweep params
    initTempVec = configSweepList[["initTempVec"]]
    stepVec = signif(10**(c(configSweepList[["stepPowersVec"]])), 2)

    # Build configs
    i = 0
    for(step in stepVec){
        
        for(initTemp in initTempVec){
            
            print(i)
            
            thisDir = file.path(topDir, paste0("sweep_", i))
            configPath = file.path(thisDir, "config.json")
            
            dir.create(thisDir, recursive = TRUE, showWarnings = FALSE)
            
            configList = list(
                "inputsKey" = inputsKey,
                "numSurveys" = numSurveys,
                "rewardRatio" = rewardRatio,
                "detectionProb" =  detectionProb,
                "niter" =  niter,
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
