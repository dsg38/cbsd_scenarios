statsDfPath = "../results/2021_03_26_cross_continental/2021_04_29_merged/output/raster_poly_stats_agg_minimal.rds"
outPath = "../results/2021_03_26_cross_continental/2021_04_29_merged/output/results_inf_polys.json"


# -----------------------------

statsDf = readRDS(statsDfPath)

# --------------------------------------

# "COD.23_1" = sud-ubangi
# "COD.20_1" = nord-ubangi

drcPolyNameVec = c(
    "mask_drc_central_small",
    "mask_drc_central_big",
    "mask_drc_nw",
    "mask_drc_central_south",
    "COD.23_1",
    "COD.20_1"
)

year = 2018

resList = list()
for(maskName in drcPolyNameVec){
    
    criteriaKey = paste(year, maskName, sep="-")
    print(criteriaKey)
    
    statsDfSubset = statsDf[statsDf$POLY_ID==maskName & statsDf$raster_year==year,]
    
    anyInfJobsDf = statsDfSubset[statsDfSubset$raster_num_fields > 0,]
    
    # TODO: Remove this '0' hack and replace with proper `jobSim` parsing for simKey
    passKeys = paste(anyInfJobsDf$scenario, anyInfJobsDf$batch, anyInfJobsDf$job, "0", sep="-")
    
    print(length(passKeys))
    
    resList[[criteriaKey]] = passKeys
}

outJson = rjson::toJSON(resList, indent=4)

readr::write_file(outJson, outPath)
