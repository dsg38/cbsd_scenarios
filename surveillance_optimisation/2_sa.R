infBrick = raster::brick("./brick.tif")

# ------------------------
i = 0
objFuncVals = c()
coordsDfList = list()

objectiveFun = function(x){
    
    detectionProb = 1
    
    numVals = length(x)
    
    xCoords = x[1:(numVals/2)]
    yCoords = x[((numVals/2)+1):numVals]
    
    coordsDf = data.frame(x=xCoords, y=yCoords)
    
    cellIndexVec = raster::cellFromXY(object=infBrick[[1]], xy=coordsDf)
    
    brickValsDf = as.data.frame(infBrick[cellIndexVec])
    
    # Probability that you don't detect per cell
    probNotDetectPerCellDf = 1 - (detectionProb * brickValsDf)
    
    # Prob that you DO detect per raster layer
    probDetectPerRasterVec = 1 - apply(X=probNotDetectPerCellDf, 2, FUN=prod)
    
    # As in parnel, we take the mean = This is the interesting choice - We need to collapse across all realisations somehow
    # TODO: Investigate returning the 'min' instead of the 'mean' to minimise how bad the worse case is... - need to think more
    probDetectAcrossRastersMean = mean(probDetectPerRasterVec)

    i <<- i + 1
    objFuncVals <<- c(objFuncVals, probDetectAcrossRastersMean)
    
    if(i%%100==0){
        print(i)    
    }
    
    # if(i<=100){
        # coordsDfList[[as.character(i)]] = cbind(coordsDf, iteration=i)
        # assign(coordsDfList[[as.character(i)]], cbind(coordsDf, iteration=i), envir = .GlobalEnv)
    
    # Put survey coords into global list 
    tmp <- get('coordsDfList',.GlobalEnv)
    tmp[[as.character(paste0("loop_", i))]] <- cbind(coordsDf, iteration=i)
    assign("coordsDfList",tmp, .GlobalEnv)
        
    # }
    
    # print(probDetectAcrossRastersMean)
    
    return(probDetectAcrossRastersMean)
    
}

# SA bit
numSurveys = 100

rasterExtent = raster::extent(infBrick)

xRand = runif(n=numSurveys, min=rasterExtent@xmin, max=rasterExtent@xmax)
yRand = runif(n=numSurveys, min=rasterExtent@ymin, max=rasterExtent@ymax)

startVec = c(xRand, yRand)

controlList = list(
    k=0.1,
    r=0.99,
    nlimit=5
)


x = optimization::optim_sa(
    fun=objectiveFun,
    start=startVec,
    maximization=TRUE,
    trace=FALSE,
    lower=c(rep(rasterExtent@xmin, numSurveys), rep(rasterExtent@ymin, numSurveys)),
    upper=c(rep(rasterExtent@xmax, numSurveys), rep(rasterExtent@ymax, numSurveys)),
    control=controlList
)

coordsDf = dplyr::bind_rows(coordsDfList)

write.csv(coordsDf, "./data/coordsDf.csv", row.names = FALSE)

# plot(objFuncVals, main=paste(controlList, collapse="_"))

# surveyDf = coordsDfList[["loop_2"]] |>
#     sf::st_as_sf(coords=c("x", "y"), crs="WGS84")
# 
# mapview::mapview(surveyDf)

# plot(x$trace)
# 
# x$function_value
# x$function_value
