args = commandArgs(trailingOnly=TRUE)

rasterStatsDfPath = args[[1]]
outPath = args[[2]]

# rasterStatsDfPath = "../results/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/output/raster_poly_stats_agg_minimal_DONE.rds"
# outPath = "../results/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/output/propYearDf.rds"

rasterStatsDf = readRDS(rasterStatsDfPath) |>
    dplyr::filter(raster_year > 2004) # Drop initial rasters as sim_year is then calc as 2003 (i.e. before sims start!)

propThresholdVec = c(0, 0.001, 0.01, 0.05, 0.1, 0.25, 0.5, 0.75)

# ------------------------------------------------

# Split by simKey/poly
splitDfList = split(
    rasterStatsDf, 
    list(
        rasterStatsDf$simKey,
        rasterStatsDf$POLY_ID
    ),
    drop=TRUE
)

# Extract first year poly inf exceeds prop threshold, otherwise Inf
getPropThresholdRows = function(
    thisDf,
    propThresholdVec
    ){
    
    thisPolyId = thisDf$POLY_ID[[1]]
    thisSimKey = thisDf$simKey[[1]]

    # Loop over different threshold proportions
    outRowList = list()
    for(propThreshold in propThresholdVec){

        # Which year rows exceed this proportion
        aboveThresholdDf = thisDf[thisDf$raster_prop_fields > propThreshold,]
        
        # Deal with never arriving case
        if(nrow(aboveThresholdDf) == 0){
            raster_year = Inf
        }else{
            raster_year = min(aboveThresholdDf$raster_year)
        }
        
        # Build row
        outRow = data.frame(
            POLY_ID=thisPolyId,
            simKey=thisSimKey,
            prop=propThreshold,
            raster_year=raster_year
        )

        # Add to list
        outRowList[[as.character(propThreshold)]] = outRow

    }

    # Merge rows
    outDf = dplyr::bind_rows(outRowList)

    return(outDf)
    
}

# Apply to all dfs
rowList = pbapply::pblapply(splitDfList, getPropThresholdRows, propThresholdVec)

# Merge
propYearDf = dplyr::bind_rows(rowList)

# Save
saveRDS(propYearDf, outPath)
