box::use(../utils/sa)
box::use(./utils_assessment)
box::use(foreach[...])
# box::reload(utils_assessment)

# Inputs - config = which optimal strategy to assess?
sweepConfigPath = here::here("surveillance/results/2022_10_07_cc_NGA_year_0/sweep/sweep_307/config.json")

detectionProb = 0.85

niter = 20

# TODO: Specify vector of detection vals to sweep over
# detectionProbVec = c(0.01, 0.1, 0.25, 0.5, 0.85)

# TODO: Get list of optimal sweep dirs from `optimalDf.csv` to specify vec of sweepConfigPath to loop over

# TODO: Use `optimalDf.csv` to plot actual optimal vs. boxplots of these results for each detectionParam

# -----------------------------------------

# Read in config
sweepConfigList = rjson::fromJSON(file=sweepConfigPath)

# TODO: Do we want to fix numSurveys to same as the optimised val or sweep this too?
rewardRatio = sweepConfigList[["rewardRatio"]]
numSurveys = sweepConfigList[["numSurveys"]]

# -----------------------------

# Define paths
sweepIndexStr = basename(dirname(sweepConfigPath))
sweepIndexInt = as.integer(stringr::str_split(sweepIndexStr, "_")[[1]][[2]])

scenarioDir = dirname(dirname(dirname(sweepConfigPath)))
simpleGridDfPath = file.path(scenarioDir, "data", "simple_grid", paste0("simple_grid_", sweepIndexStr, ".gpkg"))

optimalDfPath = file.path(scenarioDir, "data/optimalDf.csv")

inputsDir = here::here("surveillance/inputs/inf_rasters_processed", sweepConfigList[["inputsKey"]], "outputs")
infBrickPath = file.path(inputsDir, "brick.tif")
sumRasterPointsDfPath = file.path(inputsDir, "sumRasterMaskPointsDf.csv")

# Read in simple grid strategy
simpleGridDf = sf::read_sf(simpleGridDfPath)

# Read in optimal df
optimalDf = read.csv(optimalDfPath)
optimalDfRow = optimalDf[optimalDf$sweep_i==sweepIndexInt,]

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

objValVec = c()
for(i in 1:niter){

    print(i)

    coordsDf = utils_assessment$genWeightedRandomCoordsDf(
        simpleGridDf=simpleGridDf,
        sumRasterPointsDfGridNames=sumRasterPointsDfGridNames,
        numSurveys=numSurveys
    )

    # x = sf::st_as_sf(coordsDf, coords=c("x", "y"), crs="WGS84")
    # mapview::mapview(simpleGridDf, z="prop") + mapview::mapview(x)

    cellIndexVec = raster::cellFromXY(object=infBrick[[1]], xy=coordsDf)
    
    brickValsDf = as.data.frame(infBrick[cellIndexVec])

    # Calc obj func
    objVal = sa$objectiveFunc(
        brickValsDf=brickValsDf, 
        rewardRatio=rewardRatio,
        detectionProb=detectionProb
    )
    
    objValVec = c(objValVec, objVal)

}

hist(objValVec, xlim=c(0,1))
abline(v=optimalDfRow$objective_func_val)
