library(tictoc)
args = commandArgs(trailingOnly=TRUE)

simulated_annealing = function(
    objectiveFunc, 
    startCoordsDf, 
    extent, 
    rewardRatio, 
    detectionProb, 
    infBrick,
    sumRasterPointsDf, 
    niter, 
    step, 
    initTemp
    ){

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


objectiveFunc = function(
    brickValsDf, 
    rewardRatio, 
    detectionProb
    ){

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


sa_wrapper = function(
    configPath
){

    resDir = file.path(dirname(configPath), "outputs_sa")
    dir.create(resDir, showWarnings = FALSE, recursive = TRUE)

    # Parse SA params config
    configList = rjson::fromJSON(file=configPath)

    numSurveys = configList[["numSurveys"]]
    rewardRatio = configList[["rewardRatio"]]
    detectionProb = configList[["detectionProb"]]
    niter = configList[["niter"]]
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
        infBrick=infBrick,
        sumRasterPointsDf=sumRasterPointsDf,
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

}

sa_wrapper(args[[1]])
