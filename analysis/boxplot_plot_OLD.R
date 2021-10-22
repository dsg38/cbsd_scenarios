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
    plottingPriority = reorder(thisPropDf[,"display_name"], thisPropDf[,"raster_year"], FUN=quantile, probs=0.25)
    
    p = ggplot(thisPropDf, aes(x=plottingPriority, y=raster_year)) + 
        geom_boxplot() + 
        scale_y_continuous(breaks=seq(yearMin, yearMax, 5)) + 
        xlab(NULL) + 
        ylab(propAxisLabel) + 
        geom_hline(yintercept=currentYear, linetype="dashed", color = "red") +
        coord_flip(ylim=c(yearMin, yearMax))

    ggsave(outPath, p)
    
}

propYearDfRaw = read.csv("./plots/propYearDf.csv")
dispDf = read.csv(here::here("inputs/process_polys/outputs/poly_display_names.csv"))

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

yearMin = 2004
yearMax = 2054


# Read in constrainsts json
constraintList = rjson::fromJSON(file = "./results/2021_03_26_cross_continental/2021_04_29_merged/output/constraint_sim_keys.json")

# Convert to job list
getJob = function(constraintVal){
    x = stringr::str_split(constraintVal, "-")
    job = x[[1]][[3]]
    batch = x[[1]][[2]]
    
    batchJobKey = paste0(batch, "-", job)
    
    return(batchJobKey)
}

constraintListJob = list()
for(constraintKey in names(constraintList)){
    
    constraintVec = constraintList[[constraintKey]]
    
    jobVec = sapply(constraintVec, getJob, USE.NAMES=FALSE)
    
    constraintListJob[[constraintKey]] = jobVec
}

# HACK to only plot subset of polys
# x = unique(propYearDf[, c("POLY_ID", "display_name")])

dropCodes = c(
    "MOZ",
    "MWI",
    "TZA",
    "KEN"
)

propYearDf = propYearDf[!(propYearDf$POLY_ID%in%dropCodes),]



# Plot all
for(constraintKey in names(constraintListJob)){
    
    constraintJobVec = constraintListJob[[constraintKey]]
    
    propYearDfSubset = propYearDf[propYearDf$batchJobKey%in%constraintJobVec,]
    
    for(propThreshold in propThresholdVec){
        
        propThresholdStr = sprintf("%0.2f", propThreshold)
        
        outPath = file.path('./plots', paste0("boxplot_prop_", propThresholdStr, "_", constraintKey, ".png"))
        
        print(outPath)

        genPlot(
            propYearDf=propYearDfSubset,
            propThreshold=propThreshold,
            yearMin=yearMin,
            yearMax=yearMax,
            outPath=outPath
        )
        
    }
    
}

