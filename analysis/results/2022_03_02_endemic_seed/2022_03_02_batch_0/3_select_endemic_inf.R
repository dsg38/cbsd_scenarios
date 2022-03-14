# Read in year in which given poly reaches given proportion of infected fields df
propYearDf = read.csv("./data_simulations/propYearDf.csv")

# -------------------------------
# Extract simulations wherein non-endemic countries never reach 1% infection (i.e. infinite for year in which exceed 1%)
# -------------------------------

endemicCountryCodes = c(
    "KEN",
    "TZA",
    "MWI",
    "MOZ"
)

propYearDfSubset = propYearDf[!(propYearDf$POLY_ID %in% endemicCountryCodes) & propYearDf$prop==0.01 & is.infinite(propYearDf$raster_year),]

# Work out set that match above criteria in every polygon
polyIds = unique(propYearDfSubset$POLY_ID)

polyJobList = list()
for(polyId in polyIds){
    
    thisDf = propYearDfSubset[propYearDfSubset==polyId,]
    polyJobList[[polyId]] = thisDf$job
    
}

# Vector of jobs that do not exceed 1% infection at the 10 year mark in any non-endemic country
jobVecNonEndemic = Reduce(intersect, polyJobList)

# -------------------------------
# Isolate sims which reach 50% inf in all endemic polys
# -------------------------------
endemicPolyCodes = c(
    "endemic_KEN",
    "endemic_TZA",
    "endemic_MWI",
    "endemic_MOZ"
)

# Subset where at least 1 of the endemic polys exceeds 50% 
propYearDfExceed = propYearDf |>
    dplyr::filter(POLY_ID%in%endemicPolyCodes & prop==0.5 & !is.infinite(raster_year))


polyJobListEndemic = list()
for(polyId in endemicPolyCodes){
    
    thisDf = propYearDfExceed[propYearDfExceed==polyId,]
    polyJobListEndemic[[polyId]] = thisDf$job
    
}

jobVecEndemic = Reduce(intersect, polyJobListEndemic)

# -----------------------------
# Which jobs pass both criteria
# -----------------------------
jobVecBoth = intersect(jobVecNonEndemic, jobVecEndemic)

# Randomly pick one
randomPickJob = sample(jobVecBoth, 1)
readr::write_lines(randomPickJob, "./results/rand_job.txt")

# Write out propYearDf for jobs which match this criteria and jobs which don't
propYearDfCriteriaTrue = propYearDf[propYearDf$job%in%jobVecBoth,]
propYearDfCriteriaFalse = propYearDf[!(propYearDf$job%in%jobVecBoth),]

write.csv(propYearDfCriteriaTrue, "./data_simulations/propYearDfCriteriaTrue.csv", row.names=FALSE)
write.csv(propYearDfCriteriaFalse, "./data_simulations/propYearDfCriteriaFalse.csv", row.names=FALSE)
