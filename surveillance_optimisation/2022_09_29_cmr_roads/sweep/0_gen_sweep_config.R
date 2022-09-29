topDir = file.path("./results")

# Define fixed params
numSurveys = 1000
rewardRatio = 1
detectionProb = 0.85
niter = 100000

# Define sweep params
initTempVec = c(1, 10, 100, 1000)
stepVec = signif(10**(c(-2.5, -3, -3.5, -4)), 2)


# Build configs
i = 0
for(step in stepVec){
    
    for(initTemp in initTempVec){
        
        print(i)
        
        thisDir = file.path(topDir, paste0("sweep_", i))
        configPath = file.path(thisDir, "config.json")
        
        dir.create(thisDir, recursive = TRUE, showWarnings = FALSE)
        
        configList = list(
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


