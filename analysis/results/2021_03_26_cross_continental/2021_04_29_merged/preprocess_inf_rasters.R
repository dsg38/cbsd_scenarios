statsDfPath = "./output/raster_poly_stats_agg_minimal.rds"
outPath = "./output/results_inf_polys.json"

# -----------------------------

statsDf = readRDS(statsDfPath)

# --------------------------------------

# THE TWO NW DRC PROVINCES WHERE TONY REPORTED POSITIVES IN SURVEY 2017 (HENCE INF RASTER 2018.0000)
# "COD.23_1" = sud-ubangi
# "COD.20_1" = nord-ubangi

polyNameVec = c(
    # "2018-mask_drc_central_small",
    # "2018-mask_drc_central_big",
    # "2018-mask_drc_nw",
    # "2018-mask_drc_central_south",
    
    # DRC small region around confirmed positives (Monde near Kisangani)
    "2017-mask_drc_central_small",
    "2018-mask_drc_central_small",

    # NW DRC
    "2017-COD.23_1",
    "2018-COD.23_1",

    "2017-COD.20_1",
    "2018-COD.20_1",
    
    # Rwanda + Burundi first confirmed (start of year of detection + End of year (consistent with our survey assumption))
    "2009-RWA",
    "2010-RWA",

    "2011-BDI",
    "2012-BDI",
    
    # Haut-Katanga in SE DRC
    "2016-COD.3_1",
    "2017-COD.3_1",
    
    # Zambia first PCR in north
    "2017-ZMB.4_1",
    "2018-ZMB.4_1",
    
    "2017-ZMB.8_1",
    "2018-ZMB.8_1"

)

resList = list()
for(criteriaKey in polyNameVec){
    
    print(criteriaKey)
    
    criteriaKeySplit = strsplit(criteriaKey, "-")[[1]]
    maskName = criteriaKeySplit[[2]]
    year = criteriaKeySplit[[1]]
    
    statsDfSubset = statsDf[statsDf$POLY_ID==maskName & statsDf$raster_year==year,]
    
    anyInfJobsDf = statsDfSubset[statsDfSubset$raster_num_fields > 0,]
    
    # TODO: Remove this '0' hack and replace with proper `jobSim` parsing for simKey
    passKeys = paste(anyInfJobsDf$scenario, anyInfJobsDf$batch, anyInfJobsDf$job, "0", sep="-")
    
    print(length(passKeys))
    
    resList[[criteriaKey]] = passKeys
}

outJson = rjson::toJSON(resList, indent=4)

readr::write_file(outJson, outPath)
