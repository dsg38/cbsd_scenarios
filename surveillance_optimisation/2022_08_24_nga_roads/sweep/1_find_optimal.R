library(ggplot2)
library(ggpubr)

iMax = 15

traceDfList = list()
traceDfMaxList = list()
for(i in seq(0, iMax)){
    
    print(i)

    resultsDir = file.path("./results/", paste0("sweep_", i))
    traceDfPath = file.path(resultsDir, "traceDf.rds")
    # configPath = file.path(resultsDir, "config.json")
    
    if(file.exists(traceDfPath)){
        
        traceDf = readRDS(traceDfPath) |>
            dplyr::mutate(sweep_i = i)
        
        
        traceDfList[[traceDfPath]] = traceDf
        
        # Extract max per scenario
        traceDfMax = traceDf[traceDf$objective_func_val == max(traceDf$objective_func_val),]
        
        if(nrow(traceDfMax) > 1){
            
            traceDfMax = traceDfMax[traceDfMax$iteration==max(traceDfMax$iteration),]
            
            
        }
        
        traceDfMaxList[[traceDfPath]] = traceDfMax
        
        
    }
    

}

traceDfMerged = dplyr::bind_rows(traceDfList)

traceDfMaxMerged = dplyr::bind_rows(traceDfMaxList)


