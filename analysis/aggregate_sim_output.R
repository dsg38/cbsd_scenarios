box::use(./utils_process)

# scenarioDir = "../inputs/inputs_scenarios/2021_03_17_cross_continental"
simDir = "../simulations/sim_output/2021_03_26_cross_continental/2021_03_29_batch_0/"
resultDir = "./results/2021_03_26_cross_continental/2021_03_29_batch_0"

# ----------------------------------------------

dir.create(resultDir, showWarnings = FALSE, recursive = TRUE)

# ----------------------------------------------
# Aggregate all simulated survey output files
source("utils/FUNC_aggregate_management_results.R")

stackedOutPath = file.path(resultDir, "management_stacked.rds")

utils_process$aggregateManagementResults(
    simDir=simDir,
    stackedOutPath=stackedOutPath
)




# ----------------------------------------------

# inputsDir = file.path(scenarioDir, "inputs")
# indexDir = file.path(scenarioDir, "masks")
# indexDir = file.path(scenarioDir, "index")



# For key regions of interest (e.g. Kampala), extract stats for this specific region

# source("utils/FUNC_extract_poly_stats.R")

# surveyMappingPath = file.path(inputsDir, "surveyTiming.json")
# summaryOutPath = file.path(resultDir, "results_summary.rds")

# extractPolygonStats(
#     stackedDfPath=stackedOutPath,
#     surveyMappingPath=surveyMappingPath,
#     indexDir=indexDir,
#     summaryOutPath=summaryOutPath
# )


# # ----------------------------------------------
# fixedOutPath = file.path(resultDir, "results_summary_fixed.rds")

# source("utils/FUNC_drop_incomplete_sims.R")
  
# dropIncompleteSims(
#     resPath=summaryOutPath,
#     outPath=fixedOutPath,
#     simYearMin=2005,
#     simYearMax=2019
# )

# # ----------------------------------------------------------

# statisticDir = "../../cbsd_landscape_model/summary_stats/mask_stats/survey_data_C"

# targetOutPath = file.path(resultDir, "results_summary_fixed_TARGET.rds")

# source("utils/FUNC_append_target_data.R")

# appendTargetDataFunc(
#     surveyDfPath=fixedOutPath,
#     statisticDir=statisticDir, 
#     outPath=targetOutPath
# )

# # ----------------------------------------------------------

# source("utils/FUNC_minimalDfs.R")

# minimalDfs(
#     targetDfPath=targetOutPath
# )
