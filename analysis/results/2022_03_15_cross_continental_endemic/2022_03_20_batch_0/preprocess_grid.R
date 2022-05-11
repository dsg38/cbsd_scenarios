box::use(./utils_grid)

maxFittingSurveyDataYear = 2010

resultsDfTargetPath = "./output/management_results.rds"
surveyStatsDfPath = "../../../../inputs/inputs_raw/survey_rasters/cassava_data-2022_02_09/poly_stats/polys_fitting/grid_arrival_year.csv"
gridDfPath = "./output/grid_full_pass_criteria.rds"

gridSimDfOutPath = "./output/grid_sim_pass_criteria.rds"

# *For every grid in each sim, calculate whether it passes or fails each of the 4 statistic criteria*
# surveyStatsDfPath = file.path(statisticDir, "grid_arrival_year.csv")
# gridDfPath = file.path(resDirTargetLevel, "grid_full_pass_criteria.rds")

utils_grid$calcGridPassCriteriaWrapper(
    resultsDfTargetPath=resultsDfTargetPath,
    surveyStatsDfPath=surveyStatsDfPath,
    maxFittingSurveyDataYear=maxFittingSurveyDataYear,
    gridDfOutPath=gridDfPath
)

# ----------------------------------------------------------
# *Calc the per sim pass rate for each grid criteria*
# gridSimDfOutPath = file.path(resDirTargetLevel, "grid_sim_pass_criteria.rds")

utils_grid$calcPerSimGridResults(
    gridDfPath=gridDfPath,
    gridSimDfOutPath=gridSimDfOutPath
)
