box::use(../../../utils_analysis)
# box::reload(utils_analysis)

# --------------------------------------
# Which simKeys meet a set of criteria
# --------------------------------------
# Firstly, which sims meet the UGA survey constraint?
# Then cumulatively add in each of the arrivals in a given polygon
# i.e. uga survey + any infection in Rwanda by a given time
# --------------------------------------


surveyKeysList = rjson::fromJSON(file="./output/results_sim_survey.json")
infKeysList = rjson::fromJSON(file="./output/results_inf_polys.json")

# gridDf = readRDS("./output/grid_sim_pass_criteria.rds")

# Inf prop pass keys
surveyUgaKeys = intersect(surveyKeysList[["mask_uga_hole"]], surveyKeysList[["mask_uga_kam"]])

targetYearsDf = read.csv("./config/inf_target_years.csv") |>
    dplyr::filter(POLY_ID != "kampala")

targetPolyOrderVec = targetYearsDf$POLY_ID
# -----------------------------------

# Grid metric pass keys
# thisCriteria = "tol_applied_only_where_both_bool"
# gridTol = 0.48
# 
# gridDfSubset = gridDf[gridDf$criteria==thisCriteria & gridDf$propFail<=gridTol,]
# 
# x = intersect(surveyUgaKeys, gridDfSubset$simKey)

# -----------------------------------
cumulativePassKeysList = list()

# Add in all pass keys
y = readRDS("./output/raster_poly_stats_agg_minimal.rds")
cumulativePassKeysList[["all"]] = unique(y$simKey)


cumulativeKey = "uga"
cumulativePassKeysList[[cumulativeKey]] = surveyUgaKeys

statsDfList = list()
runningPassList = surveyUgaKeys

for(thisInfPoly in targetPolyOrderVec){
    
    thisInfPolyPassKeys = infKeysList[[thisInfPoly]]
    
    runningPassList = intersect(runningPassList, thisInfPolyPassKeys)

    cumulativeKey = paste(cumulativeKey, thisInfPoly, sep="-")
    cumulativePassKeysList[[cumulativeKey]] = runningPassList

    print(cumulativeKey)
    print(length(runningPassList))

    
    outRow = data.frame(
        POLY_ID=thisInfPoly,
        num_pass=length(thisInfPolyPassKeys),
        num_pass_inc_uga=length(intersect(thisInfPolyPassKeys, surveyUgaKeys)),
        num_pass_cumulative=length(runningPassList)
    )
    
    statsDfList[[thisInfPoly]] = outRow
    
}

x = dplyr::bind_rows(statsDfList)

# Save as JSON
outPath = "./output/cumulative_passKeys.json"
outJson = rjson::toJSON(cumulativePassKeysList, indent=4)
readr::write_file(outJson, outPath)
