statsDfPath = "./output/raster_poly_stats_agg_minimal.rds"
outPath = "./output/results_inf_polys.json"

# -----------------------------

statsDf = readRDS(statsDfPath)

# polysDf = sf::read_sf("../../../../inputs/inputs_raw/polygons/polys_cross_continental_constraints_host_CassavaMap.gpkg")
# sf::st_geometry(polysDf) = NULL
# 
# outDf = data.frame(
#     POLY_ID=polysDf$POLY_ID,
#     raster_year_target=NA
# )
# 
# write.csv(outDf, "./config/inf_target_years.csv", row.names = FALSE)

# Extract proportion that have any infection by a given year

# --------------------------------------
targetRasterYearDf = read.csv("./config/inf_target_years.csv")
targetRasterYearDf$raster_year_target

resList = list()
# for(criteriaKey in polyNameVec){

for(iRow in seq_len(nrow(targetRasterYearDf))){
    
    thisRow = targetRasterYearDf[iRow,]
    maskName = thisRow$POLY_ID
    year = thisRow$raster_year_target
    
    print(maskName)
    
    statsDfSubset = statsDf[statsDf$POLY_ID==maskName & statsDf$raster_year==year,]

    anyInfJobsDf = statsDfSubset[statsDfSubset$raster_num_fields > 0,]

    # TODO: Remove this '0' hack and replace with proper `jobSim` parsing for simKey
    passKeys = paste(anyInfJobsDf$scenario, anyInfJobsDf$batch, anyInfJobsDf$job, "0", sep="-")

    print(length(passKeys))

    resList[[maskName]] = passKeys
}

outJson = rjson::toJSON(resList, indent=4)

readr::write_file(outJson, outPath)
