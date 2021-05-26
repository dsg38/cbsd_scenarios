box::use(./utils_analysis)
# box::reload(utils_analysis)

resultsDfPath = "../results/2021_03_26_cross_continental/2021_04_29_merged/output/management_results.rds"
outPath = "../results/2021_03_26_cross_continental/2021_04_29_merged/output/results_sim_survey.json"
tol = 0.3

# ------------------------------------------------------------------

resultsDf = readRDS(resultsDfPath)
resList = list()

# Get keys for each constraint
resList[["mask_uga_hole"]] = utils_analysis$applyAllPolySuffix(
    resultsDf = resultsDf,
    polySuffix = "mask_uga_hole",
    tol = tol
)

# Uga kam - pass all years with tol
resList[["mask_uga_kam"]] = utils_analysis$applyAllPolySuffix(
    resultsDf = resultsDf,
    polySuffix = "mask_uga_kam",
    tol = tol
)

# Any inf in each of following polys of interest
polyNameVec = c(
    "2017_mask_drc_central_small",
    "2017_mask_drc_central_big",
    "2017_mask_drc_nw",
    "2017_mask_drc_central_south",
    "2016_COD.24_1",
    "2016_COD.3_1",
    "2017_ZMB.4_1",
    "2017_ZMB.8_1",
    "2018_ZMB.4_1",
    "2018_ZMB.8_1"
)

for(polyName in polyNameVec){

    print(polyName)

    passKeys = utils_analysis$anyInfSpecificPoly(
        resultsDf = resultsDf,
        polyName = polyName
    )

    resList[[polyName]] = passKeys

}

outJson = rjson::toJSON(resList, indent=4)
readr::write_file(outJson, outPath)
