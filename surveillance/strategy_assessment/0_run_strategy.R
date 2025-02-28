box::use(../utils/sa)
box::use(./utils_assessment)
box::use(ggplot2[...])

# Read in optimal df
niter = 2

# -----------------------------------

# scenarioNameTarget = "2022_10_07_cc_NGA_year_0"
# scenarioNameTest = "2022_10_07_cc_NGA_year_0"
# # simpleType = "simple_grid"
# simpleType = "simple_clusters"

# # ----------------------------------------

# scenarioNameTarget = "2022_12_01_di_NGA_year_1"
# scenarioNameTest = "2022_12_01_di_NGA_year_1"
# # simpleType = "simple_grid"
# simpleType = "simple_clusters"

# # ----------------------------------------

scenarioNameTarget = "2022_10_07_cc_NGA_year_0"
scenarioNameTest = "2022_12_01_di_NGA_year_1"
simpleType = "simple_grid"
# simpleType = "simple_clusters"

# # ----------------------------------------

# scenarioNameTarget = "2022_12_01_di_NGA_year_1"
# scenarioNameTest = "2022_10_07_cc_NGA_year_0"
# # simpleType = "simple_grid"
# simpleType = "simple_clusters"

# # ----------------------------------------

assessmentResultsDir = paste0("target_", scenarioNameTarget, "_test_", scenarioNameTest)



doTrial = function(
    i, 
    simpleGridDf,
    sumRasterPointsDfGridNames,
    numSurveys,
    infBrick,
    rewardRatio,
    detectionProb
){

    coordsDf = utils_assessment$genWeightedRandomCoordsDf(
        simpleGridDf=simpleGridDf,
        sumRasterPointsDfGridNames=sumRasterPointsDfGridNames,
        numSurveys=numSurveys
    )

    cellIndexVec = raster::cellFromXY(object=infBrick[[1]], xy=coordsDf)
    
    brickValsDf = as.data.frame(infBrick[cellIndexVec])

    # Calc obj func
    objVal = sa$objectiveFunc(
        brickValsDf=brickValsDf, 
        rewardRatio=rewardRatio,
        detectionProb=detectionProb
    )

    return(objVal)

}

# ----------------------------------------
rewardRatio = 1
# ----------------------------------------

scenarioDirTarget = here::here("surveillance/results", scenarioNameTarget)
scenarioDirTest = here::here("surveillance/results", scenarioNameTest)

# ----------------------------------------

optimalDfPath = file.path(scenarioDirTarget, "data/optimalDf.csv")

optimalDf = read.csv(optimalDfPath)
optimalDf$sweep_i = as.character(optimalDf$sweep_i)

numSurveysVec = sort(unique(optimalDf$numSurveys))

# Get inputs (i.e. infBrick) using scenarioNameTest
configList = utils_assessment$getConfigFromScenarioName(scenarioNameTest)
inputsDir = here::here("surveillance/inputs/inf_rasters_processed", configList[["inputsKey"]], "outputs")
infBrickPath = file.path(inputsDir, "brick.tif")
sumRasterPointsDfPath = file.path(inputsDir, "sumRasterMaskPointsDf.csv")

infBrick = raster::brick(infBrickPath)
sumRasterPointsDf = read.csv(sumRasterPointsDfPath)

# ----------------------------

i = 0
bigResultsDfList = list()
for(numSurveys in numSurveysVec){

    # Pull out subset to be assessed
    optimalDfSubset = optimalDf[optimalDf$numSurveys == numSurveys,]
    sweepIndexVec = optimalDfSubset$sweep_i

    for(sweepIndex in sweepIndexVec){

        print(i)

        sweepIndexStr = paste0("sweep_", sweepIndex)

        # Pick which sweep is the scenario to be tested
        optimalDfTargetRow = optimalDf[optimalDf$sweep_i == sweepIndex,]

        # Define paths
        simpleGridDfPath = file.path(scenarioDirTarget, "data", simpleType, paste0(sweepIndexStr, ".gpkg"))
        
        # Read in simple grid strategy
        simpleGridDf = sf::read_sf(simpleGridDfPath)

        # Process sum inf raster centroid points to classify according to the POLY_ID of each simple grid cell
        sumRasterPointsDfGridNames = utils_assessment$classifyRasterPointsDf(
            simpleGridDf = simpleGridDf,
            sumRasterPointsDf = sumRasterPointsDf
        )

        # ----------------------------------
        # NB: Loop starts here
        # ----------------------------------

        resultsDfList = list()
        diffDfList = list()
        for(iRow in seq_len(nrow(optimalDfSubset))){

            thisOptimalDfRow = optimalDfSubset[iRow,]

            x = unlist(pbmcapply::pbmclapply(
                seq(1, niter), 
                doTrial,
                simpleGridDf=simpleGridDf,
                sumRasterPointsDfGridNames=sumRasterPointsDfGridNames,
                numSurveys=numSurveys,
                infBrick=infBrick,
                rewardRatio=rewardRatio,
                detectionProb=thisOptimalDfRow$detectionProb
            ))

            resultsDfSubset = data.frame(
                sweep_i = thisOptimalDfRow$sweep_i,
                vals = x,
                numSurveys = numSurveys,
                detectionProb = thisOptimalDfRow$detectionProb,
                sweepIndex = sweepIndex,
                simpleType = simpleType
            )

            resultsDfList[[as.character(iRow)]] = resultsDfSubset
            
            # Gen diff df
            diffDfRow = data.frame(
                sweep_i = thisOptimalDfRow$sweep_i,
                optimalObjVal = thisOptimalDfRow$objective_func_val,
                sampleMedian = median(resultsDfSubset$vals)
            ) |>
                dplyr::mutate(diff = optimalObjVal - sampleMedian)
            
            diffDfList[[as.character(iRow)]] = diffDfRow

        }

        resultsDf = dplyr::bind_rows(resultsDfList)

        diffDf = dplyr::bind_rows(diffDfList)

        optimalDfNonSelf = optimalDfSubset[optimalDfSubset$sweep_i != sweepIndex,]

        plottingPriority = reorder(resultsDf[,"sweep_i"], resultsDf[,"vals"], FUN=quantile, probs=0.5)

        # Plot as boxplots
        p = ggplot(resultsDf, mapping = aes(x=plottingPriority, y=vals)) +
            geom_boxplot() +
            geom_point(data=optimalDfNonSelf, aes(x=sweep_i, y=objective_func_val), size=5, pch=4, stroke=2, col="green") +
            geom_point(data=optimalDfTargetRow, aes(x=sweep_i, y=objective_func_val), size=5, pch=4, stroke=2, col="red") +
            xlab("sweep_i") +
            ylim(0, max(optimalDf$objective_func_val))

        # Save 
        plotPath = here::here("surveillance/strategy_assessment/results", assessmentResultsDir, simpleType, paste0("numSurveys_", numSurveys), "plots", paste0("plot_", sweepIndexStr, ".png"))
        diffDfPath = here::here("surveillance/strategy_assessment/results", assessmentResultsDir, simpleType, paste0("numSurveys_", numSurveys), "data", paste0("diff_", sweepIndexStr, ".csv"))

        dir.create(dirname(plotPath), recursive = TRUE, showWarnings = FALSE)
        dir.create(dirname(diffDfPath), recursive = TRUE, showWarnings = FALSE)

        ggsave(filename=plotPath, plot=p)
        write.csv(diffDf, diffDfPath, row.names=FALSE)

        # Store all output data 
        bigResultsDfList[[as.character(i)]] = resultsDf

        i = i + 1

    }

}

bigResultsDf = dplyr::bind_rows(bigResultsDfList)
bigResultsDfPath = here::here("surveillance/strategy_assessment/results", assessmentResultsDir, simpleType, "bigResultsDf.rds")

saveRDS(bigResultsDf, bigResultsDfPath)
