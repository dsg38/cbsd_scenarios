library(tictoc)

simulated_annealing = function(func, startCoordsDf, extent, niter = 1000, step = 0.003) {

    # Initialize
    ## s stands for state
    ## f stands for function value
    ## b stands for best
    ## c stands for current
    ## n stands for neighbor
    s_b = s_c = s_n = startCoordsDf
    f_b = f_c = f_n = func(s_n)
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

        # Pick random coordinate to change
        randRowIndex = sample(rowIndexVec, 1, replace = TRUE)
        
        # Pick random location to update coord within extent
        newX = runif(1, min=extent@xmin, max=extent@xmax)
        newY = runif(1, min=extent@ymin, max=extent@ymax)

        # Update new state
        s_n = s_c
        s_n$x[randRowIndex] = newX
        s_n$y[randRowIndex] = newY

        f_n = func(s_n)
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


objectiveFun = function(coordsDf){
     
    detectionProb = 1
        
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
    
    # if(i<=100){
        # coordsDfList[[as.character(i)]] = cbind(coordsDf, iteration=i)
        # assign(coordsDfList[[as.character(i)]], cbind(coordsDf, iteration=i), envir = .GlobalEnv)
    

        
    # }
    
    # print(probDetectAcrossRastersMean)
    
    return(probDetectAcrossRastersMean)
     
}

infBrick = raster::brick("./brick.tif")

# ------------------------
i = 0
objFuncVals = c()
coordsDfList = list()

# SA bit
numSurveys = 10

rasterExtent = raster::extent(infBrick)

xRand = runif(n=numSurveys, min=rasterExtent@xmin, max=rasterExtent@xmax)
yRand = runif(n=numSurveys, min=rasterExtent@ymin, max=rasterExtent@ymax)

startVec = c(xRand, yRand)

startCoordsDf = data.frame(
    x = xRand,
    y = yRand
)

tic()
sol = simulated_annealing(objectiveFun, extent=rasterExtent, startCoordsDf = startCoordsDf)
toc()

coordsDf = dplyr::bind_rows(coordsDfList)

write.csv(coordsDf, "coordsDf.csv", row.names = FALSE)

plot(objFuncVals)

Temp = (1 -  0.003)^(1:length(objFuncVals))
tempVals = exp(-1 / Temp)

points(1-tempVals, col="red")
# schaffer = function(xx){
#      x1 = xx[1]
#      x2 = xx[2]
#      fact1 = (sin(x1^2-x2^2))^2 - 0.5
#      fact2 = (1 + 0.001*(x1^2+x2^2))^2
#      y = 0.5 + fact1/fact2
#      return(y)
# }
