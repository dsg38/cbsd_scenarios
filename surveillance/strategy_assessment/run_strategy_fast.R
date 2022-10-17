box::use(../utils/sa)
box::use(./utils_assessment)
box::use(foreach[...])
box::use(tictoc[...])

# Read in optimal df
scenarioName = "2022_10_07_cc_NGA_year_0"
sweepIndexStr = "sweep_307"
niter = 10

# ----------------------------------------
rewardRatio = 1
# ----------------------------------------

scenarioDir = here::here("surveillance/results", scenarioName)

optimalDfPath = file.path(scenarioDir, "data/optimalDf.csv")

optimalDf = read.csv(optimalDfPath)

# Pick which sweep is the scenario to be tested
sweepIndexInt = as.integer(stringr::str_split(sweepIndexStr, "_")[[1]][[2]])
optimalDfTargetRow = optimalDf[optimalDf$sweep_i == sweepIndexInt,]

# Pull out other rows with matching numSurveys and sweep across the detection params
numSurveys = optimalDfTargetRow$numSurveys
optimalDfSubset = optimalDf[optimalDf$numSurveys == numSurveys,]

# Define paths
simpleGridDfPath = file.path(scenarioDir, "data/simple_grid", paste0("simple_grid_", sweepIndexStr, ".gpkg"))

inputsDir = here::here("surveillance/inputs/inf_rasters_processed", optimalDfTargetRow$inputsKey, "outputs")
infBrickPath = file.path(inputsDir, "brick.tif")
sumRasterPointsDfPath = file.path(inputsDir, "sumRasterMaskPointsDf.csv")

# Read in simple grid strategy
simpleGridDf = sf::read_sf(simpleGridDfPath)

# Read in raster brick
infBrick = raster::brick(infBrickPath)

# Process sum inf raster centroid points to classify according to the POLY_ID of each simple grid cell
sumRasterPointsDfGridNames = utils_assessment$classifyRasterPointsDf(
    simpleGridDf = simpleGridDf,
    sumRasterPointsDfPath = sumRasterPointsDfPath
)

# ----------------------------------
# NB: Loop starts here
# ----------------------------------
doTrial = function(i, detectionProb){

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

resultsDfList = list()
for(iRow in seq_len(nrow(optimalDfSubset))){

    thisOptimalDfRow = optimalDfSubset[iRow,]

    x = unlist(pbmcapply::pbmclapply(seq(1, niter), doTrial, detectionProb=thisOptimalDfRow$detectionProb))

    resultsDfSubset = data.frame(
        sweep_i = thisOptimalDfRow$sweep_i,
        vals = x
    )

    resultsDfList[[as.character(iRow)]] = resultsDfSubset
    
    hist(x, xlim=c(0,1), main=thisOptimalDfRow$sweep_i)
    abline(v=thisOptimalDfRow$objective_func_val)


}

resultsDf = dplyr::bind_rows(resultsDfList)


# TODO: Plot as boxplots??

