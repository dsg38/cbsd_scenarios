box::use(../../../package_sim_survey/utils_analysis_sim_survey)

resultsDfPath = "./output/management_results.rds"
outPath = "./output/results_sim_survey.json"

tol = 0.25


resultsDf = readRDS(resultsDfPath)
resList = list()

# Get keys for each constraint
resList[["mask_uga_hole"]] = utils_analysis_sim_survey$applyAllPolySuffix(
    resultsDf = resultsDf,
    polySuffix = "mask_uga_hole",
    tol = tol
)

# Uga kam - pass all years with tol
resList[["mask_uga_kam"]] = utils_analysis_sim_survey$applyAllPolySuffix(
    resultsDf = resultsDf,
    polySuffix = "mask_uga_kam",
    tol = tol
)

outJson = rjson::toJSON(resList, indent=4)
readr::write_file(outJson, outPath)

