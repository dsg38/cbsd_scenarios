box::use(../utils/sa)
# box::reload(sa)

simpleGridDfPath = "../results/2022_10_07_cc_NGA_year_0/data/simple_grid/simple_grid_sweep_80.gpkg"
sumRasterPointsDfGridNamesPath = "./data/sumRasterPointsDfGridNames.csv"

inputsKey = "cc_NGA_year_0"
rewardRatio = 1
niter = 100
numSurveys = 500
detectionProb = 0.01

# Read in simple grid strategy
simpleGridDf = sf::read_sf(simpleGridDfPath)

inputsDir = here::here("surveillance/inputs/inf_rasters_processed", inputsKey, "outputs")

# Read in raster brick
infBrickPath = file.path(inputsDir, "brick.tif")
infBrick = raster::brick(infBrickPath)

# Read in
sumRasterPointsDfGridNames = read.csv(sumRasterPointsDfGridNamesPath)

# Sample from  sumRasterPointsDfGridNames proportional to the simpleGridDf prop column
# So for each grid in simpleGridDf (where prop>0), 
simpleGridDfAnyProp = simpleGridDf |>
    dplyr::filter(prop>0)

coordsDfList = list()
for(iRow in seq_len(nrow(simpleGridDfAnyProp))){
    
    thisRow = simpleGridDfAnyProp[iRow,]
    
    thisPolyId = thisRow$POLY_ID
    thisProp = thisRow$prop
    
    # Pull out subset of sumRasterPoints that fall in this mask
    sumRasterPointsDfSubset = sumRasterPointsDfGridNames[sumRasterPointsDfGridNames$POLY_ID==thisPolyId,]
    
    # Sample the proportion of points
    numSurveysSubset = round(numSurveys * thisProp)
    
    coordsDfSubset = dplyr::sample_n(sumRasterPointsDfSubset, numSurveysSubset, replace = TRUE) # TODO: SHOULD THIS BE replace=FALSE?
    
    coordsDfList[[thisPolyId]] = coordsDfSubset
    
}

coordsDf = dplyr::bind_rows(coordsDfList)

x = sf::st_as_sf(coordsDf, coords=c("x", "y"), crs="WGS84")

mapview::mapview(simpleGridDf, z="prop") + mapview::mapview(x)

# 
# cellIndexVec = raster::cellFromXY(object=infBrick[[1]], xy=coordsDf)
# 
# brickValsDf = as.data.frame(infBrick[cellIndexVec])
# 
# # Calc obj func
# x = sa$objectiveFunc(
#     brickValsDf=brickValsDf, 
#     rewardRatio=rewardRatio,
#     detectionProb=detectionProb
# )
