box::use(../../../package_sim_survey/utils_analysis_sim_survey)

# Define paths
resultsDfPath = "./output/management_results.rds"
outPath = "./output/results_sim_survey.json"

# Read in results df and setup empty list for json
resList = list()
resultsDf = readRDS(resultsDfPath)

# Define all fitting and validation years and uniform tolerance 
yearsVec = c(seq(2004, 2015), 2017)
tol = 0.25

# Build explicit list of constraints
constraintListHole = list()
constraintListKam = list()
for(thisYear in yearsVec){
    
    polyNameHole = paste0(thisYear, "_", "mask_uga_hole")
    polyNameKam = paste0(thisYear, "_", "mask_uga_kam")
    
    constraintListHole[[polyNameHole]] = tol
    constraintListKam[[polyNameKam]] = tol
    
}

# Apply constraints independently
resList[["mask_uga_hole"]] = utils_analysis_sim_survey$applyConstraintList(
    resultsDf=resultsDf,
    constraints=constraintListHole
)

resList[["mask_uga_kam"]] = utils_analysis_sim_survey$applyConstraintList(
    resultsDf=resultsDf,
    constraints=constraintListKam
)


# Save as JSON
outJson = rjson::toJSON(resList, indent=4)
readr::write_file(outJson, outPath)



