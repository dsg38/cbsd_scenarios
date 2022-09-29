# Extract all NGA rasters within 5 years after arrival

# Get target keys
cumulativePassKeys = rjson::fromJSON(file="../../analysis/results/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/output/cumulative_passKeys.json")
passKeys = cumulativePassKeys[["uga-RWA-BDI-drc_first_east-Pweto-zmb_regions_union-drc_north_central_field"]]

# Read in poly stats
polyDf = readRDS("../../analysis/results/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/output/raster_poly_stats_agg_minimal_DONE.rds") |>
    dplyr::filter(simKey %in% passKeys) |>
    dplyr::filter(nchar(POLY_ID)==3)


polyDfSplitList = split(polyDf, polyDf$POLY_ID)

polyDfSubset = polyDfSplitList[["COG"]]

# Extract the subset of sims that ever arrive in polyId
simKeysAnyPos = unique(polyDfSubset[polyDfSubset$raster_num_fields > 0, "simKey"])

dpcDfList = list()
for(thisSimKey in simKeysAnyPos){

    polyDfAnyPos = polyDfSubset |>
        dplyr::filter(simKey==thisSimKey) |>
        dplyr::filter(raster_num_fields > 0) |>
        dplyr::arrange(raster_year) |>
        dplyr::mutate(year_standardised = (dplyr::row_number() - 1))
    
    if(nrow(polyDfAnyPos)>=5){
        dpcDfList[[thisSimKey]] = polyDfAnyPos[1:5,] # Save only first 5 years
    }

}

dpcDf = dplyr::bind_rows(dpcDfList)

write.csv(dpcDf, "./data/dpcDf.csv", row.names = FALSE)

# Save just initial year
dpcDfInit = dpcDf[dpcDf$year_standardised==0,]

write.csv(dpcDfInit, "./data/dpcDfInit.csv", row.names = FALSE)
