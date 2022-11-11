box::use(../../utils/sa)
box::use(../../strategy_assessment/utils_assessment)
box::use(tictoc[...])
box::use(utils[...])

configPath = "./outputs/config.json"

resDir = file.path(dirname(configPath), "outputs")
dir.create(resDir, showWarnings = FALSE, recursive = TRUE)

# Parse SA params config
configList = rjson::fromJSON(file=configPath)

numSurveys = configList[["numSurveys"]]
rewardRatio = configList[["rewardRatio"]]
detectionProb = configList[["detectionProb"]]
niter = configList[["niter"]]
niterReps = configList[["niterReps"]]
step = configList[["step"]]
initTemp = configList[["initTemp"]]
inputsKey = configList[["inputsKey"]]

# ------------------------

inputsDir = here::here("surveillance/inputs/inf_rasters_processed", inputsKey, "outputs")
infBrickPath = file.path(inputsDir, "brick.tif")
sumRasterPointsDfPath = file.path(inputsDir, "sumRasterMaskPointsDf.csv")

print(infBrickPath)
print(sumRasterPointsDfPath)

stopifnot(file.exists(infBrickPath))
stopifnot(file.exists(sumRasterPointsDfPath))


# Load global variales
infBrick = raster::brick(infBrickPath)
sumRasterPointsDf = read.csv(sumRasterPointsDfPath) |>
    sf::st_as_sf(coords=c("x", "y"), crs="WGS84", remove=FALSE) |>
    dplyr::mutate(point_i = (dplyr::row_number() - 1))

# ----------------------------------
# Setup
# ----------------------------------

rasterExtent = raster::extent(infBrick)

# ----------------------------------
# Randomly sample from the full list of possible centroids
startCoordsDf = dplyr::sample_n(sumRasterPointsDf, numSurveys, replace = TRUE)


# Read in the mega pre-buffered points df
preBufferedDf = sf::read_sf("./data/preBufferedDf.gpkg")

# ----------------------------------
# Generate the ‘simple polygon’ weighted thing off this
genSimpleClustersSf = function(
    coordsDf
){

    # Read in from pre-buffered points df (fast)
    x = preBufferedDf[match(coordsDf$point_i, preBufferedDf$point_i),]

    # Merge (faster than sf::st_union)
    y = sf::st_as_sf(rgeos::gBuffer(as(x, "Spatial"), byid=F, width=0))
    
    bufferDf = y |>
        sf::st_sf() |>
        dplyr::rename(geometry=1) |>
        dplyr::filter(grepl("POLYGON", sf::st_geometry_type(geometry))) |>
        sf::st_cast("POLYGON") |>
        dplyr::mutate(POLY_ID = paste0("cluster_", dplyr::row_number()-1))

    # Calculate the number of survey points (coordsDf) per raster cell
    sf::sf_use_s2(FALSE)

    coordGridDf = sf::st_intersection(x = bufferDf, y = coordsDf) |>
        sf::st_drop_geometry() |>
        dplyr::group_by(POLY_ID) |>
        dplyr::count()

    sf::sf_use_s2(TRUE)

    gridStatsDf = dplyr::left_join(bufferDf, coordGridDf, by=c("POLY_ID"))

    gridStatsDf$n[is.na(gridStatsDf$n)] = 0

    # Calculate prop
    gridStatsDf$prop = gridStatsDf$n / sum(gridStatsDf$n)

    # Save
    # sf::write_sf(gridStatsDf, outPath)
    return(gridStatsDf)

}



# mapview::mapview(clusterDf, z="prop")

# ----------------------------------
# Evaluate how good that is - n=1 for now (using existing simple assessment tool)



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




newObjectiveFunc = function(
    startCoordsDf
){

    # Calculate clusters from points
    clusterDf = genSimpleClustersSf(startCoordsDf)

    # Process sum inf raster centroid points to classify according to the POLY_ID of each simple grid cell
    sumRasterPointsDfGridNames = utils_assessment$classifyRasterPointsDf(
        simpleGridDf = clusterDf,
        sumRasterPointsDfPath = sumRasterPointsDfPath
    )

    objectiveValVec = unlist(pbmcapply::pbmclapply(
        seq(1, niterReps), 
        doTrial,
        simpleGridDf=clusterDf,
        sumRasterPointsDfGridNames=sumRasterPointsDfGridNames,
        numSurveys=numSurveys,
        infBrick=infBrick,
        rewardRatio=rewardRatio,
        detectionProb=detectionProb
    ))


    objectiveVal = mean(objectiveValVec)

    return(objectiveVal)

}



# simulated_annealing = function(
#     objectiveFunc, 
#     startCoordsDf, 
#     extent, 
#     rewardRatio, 
#     detectionProb, 
#     infBrick,
#     sumRasterPointsDf, 
#     niter, 
#     step, 
#     initTemp
#     ){

#     box::use(stats[...])
tic()
# Initialize
## s stands for state
## f stands for function value
## b stands for best
## c stands for current
## n stands for neighbor
## v stands for value (i.e. cached brickDf thing)
s_b = s_c = startCoordsDf

f_b = f_c = newObjectiveFunc(startCoordsDf)

numPoints = nrow(startCoordsDf)
rowIndexVec = seq(1, numPoints)

# Initialise data storage
tempVec = c()
objFuncVals = c()
coordsDfList = list()

for(k in 1:niter){
    
    # print(k)
    if(k%%10==0){
        print(k)
    }

    temp = initTemp * (1 - step)^k
    
    # Pick random coordinate to change
    randRowIndex = sample(rowIndexVec, 1, replace = TRUE)
    
    # Pick random location to update coord within extent
    newCoord = dplyr::sample_n(sumRasterPointsDf, 1, replace = TRUE)
    
    # Update new state
    s_n = s_c
    s_n$x[randRowIndex] = newCoord$x
    s_n$y[randRowIndex] = newCoord$y

    # Calculate new objFunc
    f_n = newObjectiveFunc(s_n)
    
    # update current state
    if(f_n > f_c || runif(1, 0, 1) < exp(-abs(f_n - f_c) / temp)){
        s_c = s_n
        f_c = f_n
    }
    
    # Update best state
    if(f_n > f_b){
        s_b = s_n
        f_b = f_n
    }

    # Store data values
    tempVec = c(tempVec, temp)
    objFuncVals = c(objFuncVals, f_c)
    coordsDfList[[as.character(paste0("loop_", k))]] = cbind(s_c, iteration=k)
    
}

toc()

# Return data

# Probability of accepting the worst possible move in terms of the main componant of the obj func
prop_worst_move_A = exp(-(rewardRatio/tempVec))

# Probability of accepting the worst possible move in terms of the (1 - rewardRatio) componant of the obj func
prob_worst_move_B = exp(-((1-rewardRatio)/tempVec))


traceDf = data.frame(
    iteration=seq(1, niter),
    temp=tempVec,
    objective_func_val=objFuncVals,
    prop_worst_move_A=prop_worst_move_A,
    prob_worst_move_B=prob_worst_move_B
)

coordsDf = dplyr::bind_rows(coordsDfList)

resultsList = list(
    traceDf=traceDf,
    coordsDf=coordsDf
)

    # return(resultsList)
# }



x = genSimpleClustersSf(s_b)
# mapview::mapview(x, z="prop")





# # ----------------------------------
# # Simmulated annealing
# # ----------------------------------

# tic()

# resultsList = sa$simulated_annealing(
#     objectiveFunc=sa$objectiveFunc, 
#     startCoordsDf=startCoordsDf, 
#     extent=rasterExtent, 
#     rewardRatio=rewardRatio,
#     detectionProb=detectionProb,
#     infBrick=infBrick,
#     sumRasterPointsDf=sumRasterPointsDf,
#     niter=niter,
#     step=step,
#     initTemp=initTemp
# )

# toc()

# traceDf = resultsList[["traceDf"]]
# coordsDf = resultsList[["coordsDf"]]

# # ----------------------------------
# # Save results
# traceDfPath = file.path(resDir, "traceDf.rds")
# coordsDfPath = file.path(resDir, "coordsDf.rds")

# saveRDS(traceDf, traceDfPath)
# saveRDS(coordsDf, coordsDfPath)
