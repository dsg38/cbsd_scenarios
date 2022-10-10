
configSweepPath = "./2022_10_07_cc_NGA_year_0/config_sweep.json"

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

                traceDfPath = file.path(thisDir, "outputs", "traceDf.rds")
                coordsDfPath = file.path(thisDir, "outputs", "coordsDf.rds")

                if((!file.exists(traceDfPath)) | (!file.exists(coordsDfPath))){
                    print("rats")
                }

                # configList = list(
                #     "inputsKey" = inputsKey,
                #     "rewardRatio" = rewardRatio,
                #     "niter" =  niter,

                #     "numSurveys" = numSurveys,
                #     "detectionProb" =  detectionProb,
                #     "step" = step,
                #     "initTemp" = initTemp
                # )
                


                i = i + 1   
                
            }
        
        }

    }

}

