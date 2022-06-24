args = commandArgs(trailingOnly=TRUE)
box::use(../../../package_sim_survey/utils_process)

config = rjson::fromJSON(file="./config/config_paths.json")

launchScriptPath = here::here(config[["launchScriptPath"]])

# ----------------------------------------------------
# Parse launch script and assign key variables
launchScriptData = utils_process$parseLaunchScript(launchScriptPath)

scenario = launchScriptData[["scenario"]]
batch = launchScriptData[["batch"]]
scenarioInputsDir = launchScriptData[["inputsDir"]]

# ----------------------------------------------

simDir = here::here("simulations/sim_output", scenario, batch)
resultsDir = here::here("analysis/results", scenario, batch, "output")

simInputsDir = file.path(scenarioInputsDir, "inputs")
surveyMappingPath = file.path(simInputsDir, "surveyTiming.json")


# ----------------------------------------------

dir.create(resultsDir, showWarnings = FALSE, recursive = TRUE)

# ----------------------------------------------

# Parse optional args to only process a subset
startRowIndex = NULL
endRowIndex = NULL
stackedPathOut = file.path(resultsDir, "management_stacked.rds")
resultsDfSummaryOutPath = file.path(resultsDir, "resultsDfSummary.rds")

if(length(args) == 3){
    startRowIndex = as.numeric(args[[1]])
    endRowIndex = as.numeric(args[[2]])
    stackedPathOut = file.path(resultsDir, paste0("management_stacked_", args[[3]], ".rds"))
    resultsDfSummaryOutPath = file.path(resultsDir, paste0("resultsDfSummary", args[[3]], ".rds"))
}

# ----------------------------------------------
# Aggregate all simulated survey output files
utils_process$aggregateManagementResults(
    simDir=simDir,
    stackedPathOut=stackedPathOut,
    startRowIndex=startRowIndex,
    endRowIndex=endRowIndex
)

# ----------------------------------------------
# For key regions of interest (e.g. Kampala), extract **SIM SURVEY** stats for this specific region
resultsDfSummary = utils_process$extractPolygonStats(
    stackedDfPath=stackedPathOut,
    surveyMappingPath=surveyMappingPath,
    indexDir=indexDir
)

saveRDS(resultsDfSummary, resultsDfSummaryOutPath)
