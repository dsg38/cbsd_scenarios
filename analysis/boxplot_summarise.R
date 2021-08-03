rasterStatsDf = readRDS("./results/2021_03_26_cross_continental/2021_04_29_merged/output/raster_poly_stats_agg_minimal_SMALL.rds")

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

# Extract arrival year, otherwise Inf
getArrivalYearRow = function(thisDf){
    
    thisJobId = thisDf$job[[1]]
    thisPolyId = thisDf$POLY_ID[[1]]
    thisBatch = thisDf$batch[[1]]
    
    # What is arrival year?
    anyInfDf = thisDf[thisDf$raster_num_fields > 0,]
    
    # Deal with never arriving case
    if(nrow(anyInfDf) == 0){
        arrivalYear = Inf
    }else{
        arrivalYear = min(anyInfDf$raster_year)    
    }
    
    outRow = data.frame(
        POLY_ID=thisPolyId,
        job=thisJobId,
        batch=thisBatch,
        arrival_year=arrivalYear
    )
}

# Apply to all dfs
rowList = pbapply::pblapply(splitDfList, getArrivalYearRow)

# Merge
arrivalDf = dplyr::bind_rows(rowList)

# Save
write.csv(arrivalDf, "plots/arrivalDf.csv", row.names = FALSE)
