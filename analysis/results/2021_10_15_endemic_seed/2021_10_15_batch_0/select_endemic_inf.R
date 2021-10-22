box::use(utils_epidem/utils_epidem)

propYearDf = read.csv("./output/propYearDf.csv")

endemicCodes = c(
    "KEN",
    "TZA",
    "MWI",
    "MOZ"
)

# Extract non endemic countries at threshold 1% & don't exceed this threshold in under 10 years
propYearDfSubset = propYearDf[!(propYearDf$POLY_ID %in% endemicCodes) & propYearDf$prop==0.01,] |>
    dplyr::filter(raster_year > 10)

# Work out set that match above criteria in every polygon
polyIds = unique(propYearDfSubset$POLY_ID)

polyJobList = list()
for(polyId in polyIds){
    
    thisDf = propYearDfSubset[propYearDfSubset==polyId,]
    polyJobList[[polyId]] = thisDf$job
    
}

# Vector of jobs that do not exceed 1% infection at the 10 year mark in any non-endemic country
jobVecSubset = Reduce(intersect, polyJobList)

# Randomly pick one
randomPickJob = sample(jobVecSubset, 1)
readr::write_lines(randomPickJob, "./results/rand_job.txt")

# Write out propYearDf for jobs which match this criteria and jobs which don't
propYearDfCriteriaTrue = propYearDf[propYearDf$job%in%jobVecSubset,]
propYearDfCriteriaFalse = propYearDf[!(propYearDf$job%in%jobVecSubset),]

write.csv(propYearDfCriteriaTrue, "./output/propYearDfCriteriaTrue.csv", row.names=FALSE)
write.csv(propYearDfCriteriaFalse, "./output/propYearDfCriteriaFalse.csv", row.names=FALSE)

