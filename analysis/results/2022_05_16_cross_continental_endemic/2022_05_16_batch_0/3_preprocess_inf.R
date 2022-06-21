statsDfPath = "./output/raster_poly_stats_agg_minimal.rds"
outPath = "./output/results_inf_polys.json"

# --------------------------------------
# Extract simKeys for sims that have any infection in a given poly by the target year

statsDf = readRDS(statsDfPath)

targetRasterYearDf = read.csv("./config/inf_target_years.csv") |>
    dplyr::filter(POLY_ID != "kampala")

resList = list()
for(iRow in seq_len(nrow(targetRasterYearDf))){
    
    thisRow = targetRasterYearDf[iRow,]
    maskName = thisRow$POLY_ID
    year = thisRow$raster_year_target
    
    print(maskName)
    
    statsDfSubset = statsDf[statsDf$POLY_ID==maskName & statsDf$raster_year==year,]

    anyInfJobsDf = statsDfSubset[statsDfSubset$raster_num_fields > 0,]

    passKeys = anyInfJobsDf$simKey

    print(length(passKeys))

    resList[[maskName]] = passKeys
}

outJson = rjson::toJSON(resList, indent=4)

readr::write_file(outJson, outPath)
