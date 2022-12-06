box::use(ggplot2[...])

topDir = "./results/2022_10_07_cc_NGA_year_0"

optimalDfPath = "../results/2022_10_07_cc_NGA_year_0/data/optimalDf.csv"

realDfPath = "./real_world/outputs/cc_NGA_year_0/realWorldSurveyPerformance.csv"

# ------------------------------------------

optimalDfRaw = read.csv(optimalDfPath)

optimalDfA = optimalDfRaw |>
    dplyr::mutate(simpleType="simple_grid")
optimalDfB = optimalDfRaw |>
    dplyr::mutate(simpleType="simple_clusters")

optimalDf = rbind(
    optimalDfA,
    optimalDfB
)

bigResultsDfPathList = list.files(path=topDir, pattern="bigResultsDf.rds", recursive = TRUE, full.names = TRUE)

stackedDfList = list()
for(thisPath in bigResultsDfPathList){
    stackedDfList[[thisPath]] = readRDS(thisPath)
}

stackedDf = dplyr::bind_rows(stackedDfList)

# -------------------------------------------
# Pull out 1000 NGA real survey
realDf = read.csv(realDfPath) |>
    dplyr::filter(targetYear == 2020) |>
    dplyr::mutate(simpleType="simple_grid")

stackedDf$detectionProb = factor(stackedDf$detectionProb)
optimalDf$detectionProb = factor(optimalDf$detectionProb)
realDf$detectionProb = factor(realDf$detectionProb)
# ---------------------------------

for(numSurveys in sort(unique(stackedDf$numSurveys))){
    
    print(numSurveys)
    
    optimalDfSubset = optimalDf[optimalDf$numSurveys == numSurveys,]
    
    stackedDfNumSurveys = stackedDf[stackedDf$numSurveys==numSurveys,]
    
    for(sweepIndex in sort(unique(stackedDfNumSurveys$sweepIndex))){
        
        print(sweepIndex)
        
        stackedDfSubset = stackedDfNumSurveys[stackedDfNumSurveys$sweepIndex==sweepIndex,]
        
        optimalDfTargetRow = optimalDf[optimalDf$sweep_i == sweepIndex,]
        optimalDfNonSelf = optimalDfSubset[optimalDfSubset$sweep_i != sweepIndex,]
        
        p = ggplot(stackedDfSubset, mapping = aes(x=detectionProb, y=vals, fill=simpleType)) +
            geom_boxplot(lwd=0.1) +
            geom_point(data=optimalDfNonSelf, aes(x=detectionProb, y=objective_func_val), size=5, pch=18, col="green", show.legend = FALSE) +
            geom_point(data=optimalDfTargetRow, aes(x=detectionProb, y=objective_func_val), size=5, pch=18, col="red", show.legend = FALSE) +
            xlab("Field level detection sensitivity") +
            ylab("Objective function value") +
            guides(fill=guide_legend("Strategy")) +
            ylim(0, max(optimalDf$objective_func_val))
        
        # Add real data baseline to 1000 numSurvey plot
        if(numSurveys==1000){
            
            print("Adding baseline")
            p = p + 
                geom_point(data=realDf, aes(x=detectionProb, y=objVal), size=3, pch=18, col="blue", show.legend = FALSE)

        }


        outPath = file.path(topDir, "plots_joint", paste0("plot_numSurveys_", numSurveys, "_sweep_", sweepIndex, ".png"))
        dir.create(dirname(outPath), showWarnings = FALSE, recursive = TRUE)
        
        ggsave(filename=outPath, plot=p)

        
    }
    
    
}


