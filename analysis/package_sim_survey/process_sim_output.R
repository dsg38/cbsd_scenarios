args = commandArgs(trailingOnly=TRUE)
box::use(./utils_process)
# box::reload(utils_process)

configPath = args[[1]]

config = rjson::fromJSON(file=configPath)

launchScriptPath = here::here(config[["launchScriptPath"]])
# launchScriptPath = "../../simulations/launch/2022_03_15_cross_continental_endemic_launch.sh"

# ----------------------------------------------------
# Parse launch script and assign key variables
launchScriptData = utils_process$parseLaunchScript(launchScriptPath)

scenario = launchScriptData[["scenario"]]
batch = launchScriptData[["batch"]]
scenarioInputsDir = launchScriptData[["inputsDir"]]

# Parse scenario inputs config
surveyConfigData = utils_process$parseScenarioConfig(launchScriptData$inputsDir)
surveyPolyStatsDir = surveyConfigData[["surveyPolyStatsDir"]]

# ----------------------------------------------

simDir = here::here("simulations/sim_output", scenario, batch)
resultsDir = here::here("analysis/results", scenario, batch, "output")

simInputsDir = file.path(scenarioInputsDir, "inputs")
indexDir = file.path(scenarioInputsDir, "survey_poly_index")
surveyMappingPath = file.path(simInputsDir, "surveyTiming.json")

# ----------------------------------------------

progressDfPath = file.path(simDir, "progress.csv")
resultsPathOut = file.path(resultsDir, "management_results.rds")

# ----------------------------------------------

dir.create(resultsDir, showWarnings = FALSE, recursive = TRUE)

# ----------------------------------------------

# Parse optional args to only process a subset
startRowIndex = NULL
endRowIndex = NULL
stackedPathOut = file.path(resultsDir, "management_stacked.rds")

if(length(args) == 4){
    startRowIndex = as.numeric(args[[2]])
    endRowIndex = as.numeric(args[[3]])
    stackedPathOut = file.path(resultsDir, paste0("management_stacked", args[[4]], ".rds"))
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

# ----------------------------------------------
# If any sims missing full set of sim survey output, drop them 
resultsDfDropSurvey = utils_process$dropIncompleteSimsSimSurvey(
    resDf=resultsDfSummary,
    indexDir=indexDir
)

# ----------------------------------------------
# Drop any sims that haven't finished (based on progress.csv per batch)
resultsDfDropSim = utils_process$dropSimsNotFinished(
    resultsDf=resultsDfDropSurvey,
    paramsDf=launchScriptData$paramsDf,
    progressDfPath=progressDfPath
)

# ----------------------------------------------------------
# Append the target inf prop data for each polygon for surveys
resultsDfTarget = utils_process$appendSurveyDataTargetData(
    surveyDf=resultsDfDropSim,
    surveyPolyStatsDir=surveyPolyStatsDir
)

# ----------------------------------------------------------
# Write out results
saveRDS(resultsDfTarget, resultsPathOut)
