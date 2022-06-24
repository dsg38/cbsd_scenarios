box::use(../../../package_sim_survey/utils_process)

config = rjson::fromJSON(file="./config/config_paths.json")

launchScriptPath = here::here(config[["launchScriptPath"]])

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

indexDir = file.path(scenarioInputsDir, "survey_poly_index")

# ----------------------------------------------

progressDfPath = file.path(simDir, "progress.csv")

resultsPathOut = file.path(resultsDir, "management_results.rds")

# ----------------------------------------------

resultsDfSummary = readRDS("./output/resultsDfSummary.rds")

length(unique(resultsDfSummary$job))
# ----------------------------------------------
# If any sims missing full set of sim survey output, drop them 
resultsDfDropSurvey = utils_process$dropIncompleteSimsSimSurvey(
    resDf=resultsDfSummary,
    indexDir=indexDir
)

length(unique(resultsDfDropSurvey$job))

saveRDS(resultsDfDropSurvey, "./output/drop_A.rds")

# ----------------------------------------------
# Drop any sims that haven't finished (based on progress.csv per batch)
resultsDfDropSim = utils_process$dropSimsNotFinished(
    resultsDf=resultsDfDropSurvey,
    paramsDf=launchScriptData$paramsDf,
    progressDfPath=progressDfPath
)

length(unique(resultsDfDropSim$job))

saveRDS(resultsDfDropSim, "./output/drop_B.rds")

# ----------------------------------------------------------
# Append the target inf prop data for each polygon for surveys
resultsDfTarget = utils_process$appendSurveyDataTargetData(
    surveyDf=resultsDfDropSim,
    surveyPolyStatsDir=surveyPolyStatsDir
)

# ----------------------------------------------------------
# Write out results
saveRDS(resultsDfTarget, resultsPathOut)
