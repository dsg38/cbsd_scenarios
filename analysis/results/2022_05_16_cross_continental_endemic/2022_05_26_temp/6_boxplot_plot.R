box::use(ggplot2[...])

propYearDfRaw = read.csv("./output/propYearDf.csv") |>
    dplyr::mutate(sim_year = raster_year - 1)

dispDf = read.csv("../../../../inputs/process_polys/outputs/poly_display_names.csv")
# "/Users/dsg38/Documents/gilligan_lab/cbsd_scenarios/inputs/process_polys/outputs/poly_display_names.csv"
# dispDf = read.csv("./config/inf_target_years.csv") |>
#     dplyr::filter(POLY_ID!="kampala")

plotDir = "./plots/"

cumulativePassKeys = rjson::fromJSON(file="./output/cumulative_passKeys.json")

# ----------------------------------------------------------------------------

dir.create(plotDir, recursive = TRUE, showWarnings = FALSE)

# x = propYearDfRaw[is.na(propYearDfRaw$display_name),]

# Append display name
propYearDfRaw = dplyr::left_join(propYearDfRaw, dispDf, by="POLY_ID")
if(any(is.na(propYearDfRaw))){
    stop("Missing display names")
}

# Append arrival years
arrivalDf = read.csv("./config/inf_target_years.csv") |>
    dplyr::filter(POLY_ID != "kampala") |>
    dplyr::select(POLY_ID, report_year, raster_year_target)

propYearDf = dplyr::left_join(propYearDfRaw, arrivalDf, by="POLY_ID")

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
        
        # browser()
        
        # Decide order
        plottingPriority = reorder(thisPropDf[,"display_name"], thisPropDf[,"sim_year"], FUN=quantile, probs=0.5)
        
        
        p = ggplot(thisPropDf, aes(x=plottingPriority, y=sim_year)) + 
            geom_boxplot() +
            # geom_point(data=dispDf, aes(x =display_name, y=report_year), size=5, pch=4, stroke=2, col="green") +
            coord_flip(ylim=c(yearMin, yearMax)) +
            ggtitle(paste0("Proportion of fields infected: ", propThresholdStr)) +
            scale_y_continuous(breaks=seq(yearMin, yearMax, 5)) +
            xlab(NULL) #+
        # ylab(propAxisLabel)
        
        
        # p
        ggsave(outPath, p)
        
        
    }
    
}


