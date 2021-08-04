box::use(ggplot2[...])

genPlot = function(
    propYearDf,
    propThreshold,
    yearMin,
    yearMax,
    outPath
){
    # HACK: Converts infs to plottable vals so boxplot isn't skewed
    infReplaceVal = 5000
    
    # Extract subset of df corresponding to correct threshold
    thisPropDf = propYearDf[propYearDf$prop==propThreshold,]
    
    if(propThreshold==0){
        propAxisLabel = "Predicted year of \nCBSD introduction"
    }else{
        propThresholdStr = sprintf("%0.2f", propThreshold)
        propAxisLabel = paste0("Predicted year proportion of CBSD \ninfected fields exceeds: ", propThresholdStr)
    }
    
    # Get current year
    currentYear = lubridate::year(Sys.Date())
    
    # Replace infs
    thisPropDf$raster_year[is.infinite(thisPropDf$raster_year)] = infReplaceVal
    
    # Decide order
    plottingPriority = reorder(thisPropDf[,"POLY_ID"], thisPropDf[,"raster_year"], FUN=quantile, probs=0.75)
    
    p = ggplot(thisPropDf, aes(x=plottingPriority, y=raster_year)) + 
        geom_boxplot() + 
        scale_y_continuous(breaks=seq(yearMin, yearMax, 5)) + 
        xlab(NULL) + 
        ylab(propAxisLabel) + 
        geom_hline(yintercept=currentYear, linetype="dashed", color = "red") +
        coord_flip(ylim=c(yearMin, yearMax))

    ggsave(outPath, p)
    
}

propYearDf = read.csv("./plots/propYearDf.csv")

propThresholdVec = unique(propYearDf$prop)

yearMin = 2004
yearMax = 2054

for(propThreshold in propThresholdVec){
    
    outPath = file.path('./plots', paste0("boxplot_prop_", propThreshold, ".png"))
    
    genPlot(
        propYearDf=propYearDf,
        propThreshold=propThreshold,
        yearMin=yearMin,
        yearMax=yearMax,
        outPath=outPath
    )
    
}
