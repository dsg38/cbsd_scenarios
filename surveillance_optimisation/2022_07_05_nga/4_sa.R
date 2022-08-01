library(tictoc)

set.seed(10)

simulated_annealing = function(objectiveFunc, startCoordsDf, extent, rewardRatio, detectionProb, niter = 1000, step = 0.01, initTemp=1) {

    # Initialize
    ## s stands for state
    ## f stands for function value
    ## b stands for best
    ## c stands for current
    ## n stands for neighbor
    ## v stands for value (i.e. cached brickDf thing)
    s_b = s_c = startCoordsDf

    cellIndexVec = raster::cellFromXY(object=infBrick[[1]], xy=s_c)
    v_b = v_c = as.data.frame(infBrick[cellIndexVec])

    f_b = f_c = objectiveFunc(
        brickValsDf=v_c, 
        rewardRatio=rewardRatio,
        detectionProb=detectionProb
    )
    
    # message("It\tBest\tCurrent\tNeigh\tTemp")
    # message(sprintf("%i\t%.4f\t%.4f\t%.4f\t%.4f", 0L, f_b, f_c, f_n, 1))

    numPoints = nrow(startCoordsDf)
    rowIndexVec = seq(1, numPoints)

    for (k in 1:niter) {
        
        # print(k)
        if(k%%10==0){
            print(k)
        }

        Temp = initTemp * (1 - step)^k
        
        tempVec <<- c(tempVec, Temp)

        # Pick random coordinate to change
        randRowIndex = sample(rowIndexVec, 1, replace = TRUE)
        
        # Pick random location to update coord within extent
        newCoord = dplyr::sample_n(sumRasterPointsDf, 1, replace = TRUE)
        
        # Update new state
        s_n = s_c
        s_n$x[randRowIndex] = newCoord$x
        s_n$y[randRowIndex] = newCoord$y
        
        # If first iteration, extract raster vals for all, otherwise just re-calc single value
        cellIndexNewCoord = raster::cellFromXY(object=infBrick[[1]], xy=newCoord)
        
        brickValsDfSingleIndex = as.data.frame(infBrick[cellIndexNewCoord])
        
        # Replace corresponding row in the brickValsDf
        v_n = v_c
        v_n[randRowIndex,] = brickValsDfSingleIndex
            
        f_n = objectiveFunc(
            brickValsDf=v_n, 
            rewardRatio=rewardRatio, 
            detectionProb=detectionProb
        )
        
        # update current state
        if(f_n > f_c || runif(1, 0, 1) < exp(-abs(f_n - f_c) / Temp)){
            s_c = s_n
            f_c = f_n
            v_c = v_n
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
            v_b = v_n
        }
        # message(sprintf("%i\t%.4f\t%.4f\t%.4f\t%.4f", k, f_b, f_c, f_n, Temp))
        
    }
    return(list(iterations = niter, best_value = f_b, best_state = s_b))
}


objectiveFunc = function(brickValsDf, rewardRatio, detectionProb){

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
    normNumDetections = (expectedNumCellsDetectedPerRasterMean / nrow(brickValsDf)) * (1 - rewardRatio)
    
    reward = (probDetectAcrossRastersMean*rewardRatio) + normNumDetections
    
    return(reward)
     
}

# ----------------------------------
# Define inputs
# ----------------------------------

infBrickPath = "./data/brick.tif"
sumRasterPointsDfPath = "./data/sumRasterMaskPointsDf.csv"
outDir = "./results/2022_07_19_lunch/"

# Define SA params
numSurveys = 500
rewardRatio = 0.95
detectionProb = 1
niter = 20000
step = 0.001
initTemp = 1

# ------------------------
dir.create(outDir, showWarnings = FALSE, recursive = TRUE)

# Load global variales
infBrick = raster::brick(infBrickPath)
sumRasterPointsDf = read.csv(sumRasterPointsDfPath)

# ----------------------------------
# Setup
# ----------------------------------

# Initialise data storage objects
objFuncVals = c()
tempVec = c()
coordsDfList = list()

rasterExtent = raster::extent(infBrick)

startCoordsDf = dplyr::sample_n(sumRasterPointsDf, numSurveys, replace = TRUE)

# ----------------------------------
# Simmulated annealing
# ----------------------------------

tic()

sol = simulated_annealing(
    objectiveFunc=objectiveFunc, 
    startCoordsDf=startCoordsDf, 
    extent=rasterExtent, 
    rewardRatio=rewardRatio,
    detectionProb=detectionProb,
    niter=niter,
    step=step,
    initTemp=initTemp
)

toc()

# ----------------------------------
# Save results
# ----------------------------------

# Save coords log
coordsDf = dplyr::bind_rows(coordsDfList)

coordsDfPath = file.path(outDir, "coordsDf.rds")
saveRDS(coordsDf, coordsDfPath)

# Plot trace
tracePlotPath = file.path(outDir, "trace.png")

png(tracePlotPath, width=600, height=600)
plot(objFuncVals, ylim=c(0, 1))
lines(objFuncVals, pch=16)

points(tempVec, col="red")

x = exp(-(rewardRatio/tempVec))
points(x, col="blue")

y = exp(-((1-rewardRatio)/tempVec))
points(y, col="green")
dev.off()
