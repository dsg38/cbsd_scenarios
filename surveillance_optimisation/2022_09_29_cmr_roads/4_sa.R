library(tictoc)
args = commandArgs(trailingOnly=TRUE)

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
        if(f_n > f_c || runif(1, 0, 1) < exp(-abs(f_n - f_c) / temp)){
            s_c = s_n
            f_c = f_n
            v_c = v_n
        }
        
        # Update best state
        if(f_n > f_b){
            s_b = s_n
            f_b = f_n
            v_b = v_n
        }

        # Store data values
        tempVec = c(tempVec, temp)
        objFuncVals = c(objFuncVals, f_c)
        coordsDfList[[as.character(paste0("loop_", k))]] = cbind(s_c, iteration=k)
        
    }

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

    return(resultsList)
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

# configPath = "./results/2022_08_26_test/config.json"
# infBrickPath = "./data/brick.tif"
# sumRasterPointsDfPath = "./data/sumRasterMaskPointsDf.csv"

configPath = args[[1]]
infBrickPath = args[[2]]
sumRasterPointsDfPath = args[[3]]

resDir = dirname(configPath)

# Parse SA params config
configList = rjson::fromJSON(file=configPath)

numSurveys = configList[["numSurveys"]]
rewardRatio = configList[["rewardRatio"]]
detectionProb = configList[["detectionProb"]]
niter = configList[["niter"]]
step = configList[["step"]]
initTemp = configList[["initTemp"]]

# ------------------------

# Load global variales
infBrick = raster::brick(infBrickPath)
sumRasterPointsDf = read.csv(sumRasterPointsDfPath)

# ----------------------------------
# Setup
# ----------------------------------

rasterExtent = raster::extent(infBrick)
startCoordsDf = dplyr::sample_n(sumRasterPointsDf, numSurveys, replace = TRUE)

# ----------------------------------
# Simmulated annealing
# ----------------------------------

tic()

resultsList = simulated_annealing(
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

traceDf = resultsList[["traceDf"]]
coordsDf = resultsList[["coordsDf"]]

# ----------------------------------
# Save results

traceDfPath = file.path(resDir, "traceDf.rds")
coordsDfPath = file.path(resDir, "coordsDf.rds")

saveRDS(traceDf, traceDfPath)
saveRDS(coordsDf, coordsDfPath)

# --------------------
# # Plot trace
# tracePlotPath = file.path(resDir, "trace.png")

# png(tracePlotPath, width=600, height=600)

# plot(traceDf$objective_func_val, ylim=c(0, 1))
# lines(traceDf$objective_func_val, pch=16)

# points(traceDf$temp, col="red")

# points(traceDf$prop_worst_move_A, col="blue")

# points(traceDf$prob_worst_move_B, col="green")

# dev.off()
