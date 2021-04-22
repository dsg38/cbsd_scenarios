args = commandArgs(trailingOnly=TRUE)
box::use(./utils_process)

launchScriptPath = args[[1]]

# launchScriptPath = "../simulations/launch/2021_03_29_cross_continental_launch.sh"

# ----------------------------------------------------
launchScriptData = utils_process$parseLaunchScript(launchScriptPath)

scenario = launchScriptData[["scenario"]]
batch = launchScriptData[["batch"]]
scenarioInputsDir = launchScriptData[["inputsDir"]]

# Parse scenario inputs config
surveyConfigData = utils_process$parseScenarioConfig(launchScriptData$inputsDir)

surveyBool = surveyConfigData[["surveyBool"]]
surveyPolyStatsDir = surveyConfigData[["surveyPolyStatsDir"]]

# ----------------------------------------------

simDir = here::here("simulations/sim_output", scenario, batch)
resultsDir = here::here("analysis/results", scenario, batch)

simInputsDir = file.path(scenarioInputsDir, "inputs")
indexDir = file.path(scenarioInputsDir, "survey_poly_index")
surveyMappingPath = file.path(simInputsDir, "surveyTiming.json")

# ----------------------------------------------

summaryOutPath = file.path(resultsDir, "results_summary.rds")
stackedOutPath = file.path(resultsDir, "management_stacked.rds")
fixedOutPath = file.path(resultsDir, "results_summary_fixed.rds")
targetOutPath = file.path(resultsDir, "results_summary_fixed_TARGET.rds")

# ----------------------------------------------

dir.create(resultsDir, showWarnings = FALSE, recursive = TRUE)

# ----------------------------------------------
# Aggregate all simulated survey output files
utils_process$aggregateManagementResults(
    simDir=simDir,
    stackedOutPath=stackedOutPath
)

# ----------------------------------------------

# For key regions of interest (e.g. Kampala), extract stats for this specific region
utils_process$extractPolygonStats(
    stackedDfPath=stackedOutPath,
    surveyMappingPath=surveyMappingPath,
    indexDir=indexDir,
    summaryOutPath=summaryOutPath
)

# ----------------------------------------------
# If any sims missing full set of sim survey output, drop them 
utils_process$dropIncompleteSims(
    resPath=summaryOutPath,
    outPath=fixedOutPath,
    indexDir=indexDir
)

# ----------------------------------------------------------
# Append the target inf prop data for each polygon for surveys
if(surveyBool){

    utils_process$appendSurveyDataTargetData(
        surveyDfPath=fixedOutPath,
        scenarioInputsDir=scenarioInputsDir,
        surveyPolyStatsDir=surveyPolyStatsDir,
        outPath=targetOutPath
    )

}
