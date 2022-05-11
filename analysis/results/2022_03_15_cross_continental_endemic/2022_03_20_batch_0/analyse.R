box::use(../../../utils_analysis)
# box::reload(utils_analysis)

surveyKeysList = rjson::fromJSON(file="./output/results_sim_survey.json")
gridDf = readRDS("./output/grid_sim_pass_criteria.rds")

# infKeysList = rjson::fromJSON(file="./output/results_inf_polys.json")



# Inf prop pass keys
surveyUgaKeys = intersect(surveyKeysList[["mask_uga_hole"]], surveyKeysList[["mask_uga_kam"]])

# -----------------------------------

# Grid metric pass keys
thisCriteria = "tol_applied_only_where_both_bool"
gridTol = 0.48

gridDfSubset = gridDf[gridDf$criteria==thisCriteria & gridDf$propFail<=gridTol,]


x = intersect(surveyUgaKeys, gridDfSubset$simKey)
