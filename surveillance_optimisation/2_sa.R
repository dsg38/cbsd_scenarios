library(tictoc)

simulated_annealing = function(func, startCoordsDf, extent, rewardRatio, niter = 2000, step = 0.01) {

    # Initialize
    ## s stands for state
    ## f stands for function value
    ## b stands for best
    ## c stands for current
    ## n stands for neighbor
    s_b = s_c = s_n = startCoordsDf
    f_b = f_c = f_n = func(s_n, rewardRatio)
    # message("It\tBest\tCurrent\tNeigh\tTemp")
    # message(sprintf("%i\t%.4f\t%.4f\t%.4f\t%.4f", 0L, f_b, f_c, f_n, 1))

    numPoints = nrow(startCoordsDf)
    rowIndexVec = seq(1, numPoints)

    for (k in 1:niter) {      

        # print(k)
        if(k%%100==0){
            print(k)
        }

        Temp = (1 - step)^k
        
        tempVec <<- c(tempVec, Temp)

        # Pick random coordinate to change
        randRowIndex = sample(rowIndexVec, 1, replace = TRUE)
        
        # Pick random location to update coord within extent
        newX = runif(1, min=extent@xmin, max=extent@xmax)
        newY = runif(1, min=extent@ymin, max=extent@ymax)

        # Update new state
        s_n = s_c
        s_n$x[randRowIndex] = newX
        s_n$y[randRowIndex] = newY
        
        f_n = func(s_n, rewardRatio)
        
        # update current state
        
        if(f_n > f_c || runif(1, 0, 1) < exp(-abs(f_n - f_c) / Temp)){
            s_c = s_n
            f_c = f_n
        }
        
        objFuncVals <<- c(objFuncVals, f_c)
        
        # Put survey coords into global list 
        tmp = get('coordsDfList',.GlobalEnv)
        tmp[[as.character(paste0("loop_", k))]] = cbind(s_c, iteration=k)
        assign("coordsDfList",tmp, .GlobalEnv)
        
        # update best state
        if(f_n > f_b){
            s_b = s_n
            f_b = f_n            
        }
        # message(sprintf("%i\t%.4f\t%.4f\t%.4f\t%.4f", k, f_b, f_c, f_n, Temp))
    }
    return(list(iterations = niter, best_value = f_b, best_state = s_b))
}


objectiveFun = function(coordsDf, rewardRatio){
     
    detectionProb = 1
        
    cellIndexVec = raster::cellFromXY(object=infBrick[[1]], xy=coordsDf)
    
    brickValsDf = as.data.frame(infBrick[cellIndexVec])

    # Probability that you DO detect per cell
    probDetectPerCellDf = detectionProb * brickValsDf

    # ----------------------
    # Rewarding maximising number of findings
    
    # Expected num findings cells positive per raster
    expectedNumCellsDetectedPerRaster = colSums(probDetectPerCellDf)
    
    expectedNumCellsDetectedPerRasterMean = mean(expectedNumCellsDetectedPerRaster)
    
    # ----------------------
    # Rewarding maximising number of realisations that detect
    
    # Probability that you don't detect per cell
    probNotDetectPerCellDf = 1 - probDetectPerCellDf
    
    # Prob that you DO detect per raster layer
    probDetectPerRasterVec = 1 - apply(X=probNotDetectPerCellDf, 2, FUN=prod)
    
    # As in parnel, we take the mean = This is the interesting choice - We need to collapse across all realisations somehow
    # TODO: Investigate returning the 'min' instead of the 'mean' to minimise how bad the worse case is... - need to think more
    probDetectAcrossRastersMean = mean(probDetectPerRasterVec)
    
    # ----------------------
    # Multi-objective optimisation: linear scalarization - i.e. reward both
    normNumDetections = (expectedNumCellsDetectedPerRasterMean / nrow(coordsDf)) * (1 - rewardRatio)
    
    reward = (probDetectAcrossRastersMean*rewardRatio) + normNumDetections
    
    return(reward)
     
}

infBrick = raster::brick("./data/brick.tif")


# ------------------------
objFuncVals = c()
tempVec = c()
# objFuncProbDetectVec = 

coordsDfList = list()

# SA bit
numSurveys = 10
rewardRatio = 0.95

rasterExtent = raster::extent(infBrick)

xRand = runif(n=numSurveys, min=rasterExtent@xmin, max=rasterExtent@xmax)
yRand = runif(n=numSurveys, min=rasterExtent@ymin, max=rasterExtent@ymax)

startVec = c(xRand, yRand)

startCoordsDf = data.frame(
    x = xRand,
    y = yRand
)

tic()
sol = simulated_annealing(objectiveFun, extent=rasterExtent, startCoordsDf = startCoordsDf, rewardRatio=rewardRatio)
toc()

coordsDf = dplyr::bind_rows(coordsDfList)

write.csv(coordsDf, "./data/coordsDf.csv", row.names = FALSE)

# Plot trace

png("./plots/trace/trace.png", width=600, height=600)
plot(objFuncVals)
lines(objFuncVals, pch=16)

points(tempVec, col="red")

x = exp(-(rewardRatio/tempVec))
points(x, col="blue")

y = exp(-((1-rewardRatio)/tempVec))
points(y, col="green")
dev.off()




# endCoordsDf = coordsDf[coordsDf$iteration==max(coordsDf$iteration),] |>
#     sf::st_as_sf(coords=c("x", "y"), crs="WGS84")

# sumRaster = infBrick[[1]]
# for(i in 2:8){
#     sumRaster = sumRaster + infBrick[[i]]
# }
# 

# mapview::mapview(sumRaster) #+ mapview::mapview(endCoordsDf)


