args = commandArgs(trailingOnly=TRUE)

rasterStatsDfPath = args[[1]]
outPath = args[[2]]

rasterStatsDf = readRDS(rasterStatsDfPath)

# rasterStatsDf = readRDS("./results/2022_03_02_endemic_seed/2022_03_02_batch_0/data_simulations/raster_poly_stats_agg_minimal.rds")
# outPath = "./results/2022_03_02_endemic_seed/2022_03_02_batch_0/data_simulations/propYearDf.csv"

# rasterStatsDf = readRDS("./results/2021_10_15_endemic_seed/2021_10_15_batch_0/output/raster_poly_stats_agg_minimal.rds")
# outPath = "./results/2021_10_15_endemic_seed/2021_10_15_batch_0/output/propYearDf.csv"

# rasterStatsDf = readRDS("./results/2021_03_26_cross_continental/2021_04_29_merged/output/raster_poly_stats_agg_minimal_SMALL.rds")
# outPath = "plots/propYearDf.csv"

propThresholdVec = c(seq(0, 0.1, 0.01), 0.25, 0.5, 0.75)

# ------------------------------------------------

# Split by job/batch/poly
splitDfList = split(
    rasterStatsDf, 
    list(
        rasterStatsDf$job,
        rasterStatsDf$batch,
        rasterStatsDf$POLY_ID
    ),
    drop=TRUE
)

# Extract first year poly inf exceeds prop threshold, otherwise Inf
getPropThresholdRows = function(
    thisDf,
    propThresholdVec
    ){
    
    thisJobId = thisDf$job[[1]]
    thisPolyId = thisDf$POLY_ID[[1]]
    thisBatch = thisDf$batch[[1]]

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
            job=thisJobId,
            batch=thisBatch,
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
write.csv(propYearDf, outPath, row.names = FALSE)
