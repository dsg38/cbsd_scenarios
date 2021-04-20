box::use(./utils_process)

scenarioInputsDir = "../inputs/inputs_scenarios/2021_03_17_cross_continental"
simDir = "../simulations/sim_output/2021_03_26_cross_continental/2021_03_29_batch_0/"
resultDir = "./results/2021_03_26_cross_continental/2021_03_29_batch_0"

# ----------------------------------------------
simInputsDir = file.path(scenarioInputsDir, "inputs")
indexDir = file.path(scenarioInputsDir, "survey_poly_index")
surveyMappingPath = file.path(simInputsDir, "surveyTiming.json")

# ----------------------------------------------

summaryOutPath = file.path(resultDir, "results_summary.rds")
stackedOutPath = file.path(resultDir, "management_stacked.rds")
fixedOutPath = file.path(resultDir, "results_summary_fixed.rds")

# ----------------------------------------------

dir.create(resultDir, showWarnings = FALSE, recursive = TRUE)

# ----------------------------------------------
# Aggregate all simulated survey output files

# utils_process$aggregateManagementResults(
#     simDir=simDir,
#     stackedOutPath=stackedOutPath
# )

# ----------------------------------------------

# For key regions of interest (e.g. Kampala), extract stats for this specific region
# utils_process$extractPolygonStats(
#     stackedDfPath=stackedOutPath,
#     surveyMappingPath=surveyMappingPath,
#     indexDir=indexDir,
#     summaryOutPath=summaryOutPath
# )

# # ----------------------------------------------
  
# utils_process$dropIncompleteSims(
#     resPath=summaryOutPath,
#     outPath=fixedOutPath,
#     indexDir=indexDir
# )

# # ----------------------------------------------------------

targetOutPath = file.path(resultDir, "results_summary_fixed_TARGET.rds")

source("utils/FUNC_append_target_data.R")

appendTargetDataFunc(
    surveyDfPath=fixedOutPath,
    statisticDir=indexDir, 
    outPath=targetOutPath
)

# # ----------------------------------------------------------

# source("utils/FUNC_minimalDfs.R")

# minimalDfs(
#     targetDfPath=targetOutPath
# )
