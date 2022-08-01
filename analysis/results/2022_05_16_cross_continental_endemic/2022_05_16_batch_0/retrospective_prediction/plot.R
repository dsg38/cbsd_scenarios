box::use(ggplot2[...])

dispDf = read.csv("../config/inf_target_years.csv") |>
    dplyr::filter(POLY_ID!="kampala")

propYearDfRaw = read.csv("../output/propYearDf.csv") |>
    dplyr::filter(POLY_ID %in% dispDf$POLY_ID) |>
    dplyr::mutate(sim_year = raster_year - 1)


plotDir = "./plots/"

cumulativePassKeys = rjson::fromJSON(file="../output/cumulative_passKeys.json")

# ----------------------------------------------------------------------------

dir.create(plotDir, recursive = TRUE, showWarnings = FALSE)

# Append display name
propYearDfRaw = dplyr::left_join(propYearDfRaw, dispDf, by="POLY_ID")
if(any(is.na(propYearDfRaw))){
    stop("Missing display names")
}

# Add batchJobKey
batchJobKeyVec = paste0(propYearDfRaw$batch, "-", propYearDfRaw$job)

propYearDf = cbind(
    propYearDfRaw, 
    batchJobKey=batchJobKeyVec
)

# Loop over prop thresholds
propThresholdVec = unique(propYearDf$prop)

# propThreshold = 0.05
# propThresholdStr = sprintf("%0.2f", propThreshold)
# outPath = file.path(plotDir, paste0("boxplot_prop_", propThresholdStr, ".png"))

yearMin = 2004
yearMax = max(propYearDf$sim_year[!is.infinite(propYearDf$sim_year)])

# -------------------------

for(thisCumulativePassKey in names(cumulativePassKeys)){
    
    outDir = file.path(plotDir, thisCumulativePassKey)
    
    dir.create(outDir, showWarnings = FALSE, recursive = TRUE)
    
    
    propYearDfSubset = propYearDf |> 
        dplyr::filter(simKey%in%cumulativePassKeys[[thisCumulativePassKey]])
    
    for(propThreshold in propThresholdVec){
        
        propThresholdStr = sprintf("%0.2f", propThreshold)
        
        outPath = file.path(outDir, paste0("boxplot_prop_", propThresholdStr, ".png"))
        print(outPath)
        
        # HACK: Converts infs to plottable vals so boxplot isn't skewed
        infReplaceVal = 5000
        
        # Extract subset of df corresponding to correct threshold
        thisPropDf = propYearDfSubset[propYearDfSubset$prop==propThreshold,]
        
        if(propThreshold==0){
            propAxisLabel = "Predicted year of \nCBSD introduction"
        }else{
            propThresholdStr = sprintf("%0.2f", propThreshold)
            propAxisLabel = paste0("Predicted year proportion of CBSD \ninfected fields exceeds: ", propThresholdStr)
        }
        
        # Replace infs
        thisPropDf$raster_year[is.infinite(thisPropDf$raster_year)] = infReplaceVal
        thisPropDf$sim_year[is.infinite(thisPropDf$sim_year)] = infReplaceVal
        
        # Decide order
        plottingPriority = reorder(thisPropDf[,"display_name"], thisPropDf[,"report_year"], FUN=quantile, probs=0.5)
        
        
        p = ggplot(thisPropDf, aes(x=plottingPriority, y=sim_year)) + 
            geom_boxplot() +
            geom_point(data=dispDf, aes(x =display_name, y=report_year), size=5, pch=4, stroke=2, col="green") +
            coord_flip(ylim=c(yearMin, yearMax)) +
            ggtitle(paste0("Proportion of fields infected: ", propThresholdStr)) +
            scale_y_continuous(breaks=seq(yearMin, yearMax, 5)) +
            xlab(NULL) #+
        # ylab(propAxisLabel)
        
        
        # p
        ggsave(outPath, p)
        
        
    }
    
}


