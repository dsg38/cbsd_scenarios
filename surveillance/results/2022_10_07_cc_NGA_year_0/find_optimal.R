library(plotly)
args = commandArgs(trailingOnly=TRUE)

configSweepPath = "./config_sweep.json"
# configSweepPath = "./2022_10_07_cc_NGA_year_1/config_sweep.json"
# configSweepPath = args[[1]]

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
paramDfList = list()
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
        
        paramDfList[[as.character(i)]] = paramDfMax

    }

}

paramDf = dplyr::bind_rows(paramDfList)

plot_ly() |> 
    add_trace(data = paramDf,  x=~numSurveys, y=~detectionProb, z=~objective_func_val, type="mesh3d") |>
    add_trace(data = paramDf, x=~numSurveys, y=~detectionProb, z=~objective_func_val, mode = "markers", type = "scatter3d", marker = list(size = 5, color = "red", symbol = 104))
