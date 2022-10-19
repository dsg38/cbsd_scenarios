box::use(ggplot2[...])

topDir = "./results/2022_10_07_cc_NGA_year_0"

optimalDfPath = "../results/2022_10_07_cc_NGA_year_0/data/optimalDf.csv"

optimalDfRaw = read.csv(optimalDfPath)

optimalDfRaw$sweep_i = as.character(optimalDfRaw$sweep_i)

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


for(numSurveys in sort(unique(stackedDf$numSurveys))){
    
    print(numSurveys)
    
    optimalDfSubset = optimalDf[optimalDf$numSurveys == numSurveys,]
    
    stackedDfNumSurveys = stackedDf[stackedDf$numSurveys==numSurveys,]
    
    for(sweepIndex in sort(unique(stackedDfNumSurveys$sweepIndex))){
        
        print(sweepIndex)
        
        stackedDfSubset = stackedDfNumSurveys[stackedDfNumSurveys$sweepIndex==sweepIndex,]
        
        optimalDfTargetRow = optimalDf[optimalDf$sweep_i == sweepIndex,]
        optimalDfNonSelf = optimalDfSubset[optimalDfSubset$sweep_i != sweepIndex,]
        
        plottingPriority = reorder(stackedDfSubset[,"sweep_i"], stackedDfSubset[,"vals"], FUN=quantile, probs=0.5)

        p = ggplot(stackedDfSubset, mapping = aes(x=plottingPriority, y=vals, fill=simpleType)) +
            geom_boxplot(lwd=0.1) +
            geom_point(data=optimalDfNonSelf, aes(x=sweep_i, y=objective_func_val), size=5, pch=4, stroke=2, col="green", show.legend = FALSE) +
            geom_point(data=optimalDfTargetRow, aes(x=sweep_i, y=objective_func_val), size=5, pch=4, stroke=2, col="red", show.legend = FALSE) +
            xlab("sweep_i") +
            ylim(0, max(optimalDf$objective_func_val))
        
        outPath = file.path(topDir, "plots_joint", paste0("plot_numSurveys_", numSurveys, "_sweep_", sweepIndex, ".png"))
        dir.create(dirname(outPath), showWarnings = FALSE, recursive = TRUE)
        
        ggsave(filename=outPath, plot=p)

        
    }
    
    
}


