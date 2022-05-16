box::use(../../../utils_analysis)
# box::reload(utils_analysis)

surveyKeysList = rjson::fromJSON(file="./output/results_sim_survey.json")
infKeysList = rjson::fromJSON(file="./output/results_inf_polys.json")

gridDf = readRDS("./output/grid_sim_pass_criteria.rds")




# Inf prop pass keys
surveyUgaKeys = intersect(surveyKeysList[["mask_uga_hole"]], surveyKeysList[["mask_uga_kam"]])

# -----------------------------------

# Grid metric pass keys
# thisCriteria = "tol_applied_only_where_both_bool"
# gridTol = 0.48
# 
# gridDfSubset = gridDf[gridDf$criteria==thisCriteria & gridDf$propFail<=gridTol,]
# 
# x = intersect(surveyUgaKeys, gridDfSubset$simKey)

# -----------------------------------

statsDfList = list()
runningPassList = surveyUgaKeys
for(thisInfPoly in names(infKeysList)){
    
    thisInfPolyPassKeys = infKeysList[[thisInfPoly]]
    
    runningPassList = intersect(runningPassList, thisInfPolyPassKeys)
    
    outRow = data.frame(
        POLY_ID=thisInfPoly,
        num_pass=length(thisInfPolyPassKeys),
        num_pass_inc_uga=length(intersect(thisInfPolyPassKeys, surveyUgaKeys)),
        num_pass_cumulative=length(runningPassList)
    )
    
    statsDfList[[thisInfPoly]] = outRow
    
}

x = dplyr::bind_rows(statsDfList)
