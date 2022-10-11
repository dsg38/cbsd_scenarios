#' @export
genConfigs = function(
    configSweepPath
    ){

    configSweepList = rjson::fromJSON(file=configSweepPath)

    # Define output dir
    topDir = file.path(dirname(configSweepPath), "sweep")

    # Define fixed params
    inputsKey = configSweepList[["inputsKey"]]
    rewardRatio = configSweepList[["rewardRatio"]]
    niter = configSweepList[["niter"]]

    # Define sweep params
    numSurveysVec = configSweepList[["numSurveysVec"]]
    detectionProbVec = configSweepList[["detectionProbVec"]]

    initTempVec = configSweepList[["initTempVec"]]
    stepVec = signif(10**(c(configSweepList[["stepPowersVec"]])), 2)

    # Build configs
    i = 0

    for(numSurveys in numSurveysVec){

        for(detectionProb in detectionProbVec){

            for(step in stepVec){
                
                for(initTemp in initTempVec){
                    
                    print(i)
                    
                    thisDir = file.path(topDir, paste0("sweep_", i))
                    configPath = file.path(thisDir, "config.json")
                    
                    dir.create(thisDir, recursive = TRUE, showWarnings = FALSE)
                    
                    configList = list(
                        "inputsKey" = inputsKey,
                        "rewardRatio" = rewardRatio,
                        "niter" =  niter,

                        "numSurveys" = numSurveys,
                        "detectionProb" =  detectionProb,
                        "step" = step,
                        "initTemp" = initTemp
                    )
                    
                    # Save
                    configStr = jsonlite::toJSON(configList, auto_unbox = TRUE, pretty = TRUE)
                    
                    readr::write_lines(configStr, file=configPath)
                    
                    i = i + 1   
                    
                }
            
            }

        }

    }
    
}

#' @export
genSweepOptimalDf = function(configSweepPath){

    configSweepList = rjson::fromJSON(file=configSweepPath)

    # Define output dir
    topDir = file.path(dirname(configSweepPath), "sweep")

    # Define fixed params
    inputsKey = configSweepList[["inputsKey"]]
    rewardRatio = configSweepList[["rewardRatio"]]
    niter = configSweepList[["niter"]]

    # Define sweep params
    numSurveysVec = configSweepList[["numSurveysVec"]]
    detectionProbVec = configSweepList[["detectionProbVec"]]

    initTempVec = configSweepList[["initTempVec"]]
    stepVec = signif(10**(c(configSweepList[["stepPowersVec"]])), 2)

    # Build configs
    i = 0
    traceDfMaxList = list()
    optimalDfList = list()
    for(numSurveys in numSurveysVec){

        for(detectionProb in detectionProbVec){

            # For the hyperparm sweep for each numSurveys / detectionProb combo, pull out the best hyperparams
            traceDfMaxSubsetList = list()

            for(step in stepVec){
                
                for(initTemp in initTempVec){
                    
                    print(i)

                    thisDir = file.path(topDir, paste0("sweep_", i))
                    configPath = file.path(thisDir, "config.json")
                    configList = rjson::fromJSON(file=configPath)

                    configDf = data.frame(configList)

                    traceDfPath = file.path(thisDir, "outputs", "traceDf.rds")

                    traceDf = readRDS(traceDfPath) |>
                        dplyr::mutate(
                            sweep_i = i
                        )

                    # Extract max per scenario
                    traceDfMax = traceDf[traceDf$objective_func_val == max(traceDf$objective_func_val),]
                    
                    if(nrow(traceDfMax) > 1){
                        traceDfMax = traceDfMax[traceDfMax$iteration==max(traceDfMax$iteration),]
                    }
                    
                    traceDfMaxConfig = cbind(traceDfMax, configDf)
                    
                    traceDfMaxList[[traceDfPath]] = traceDfMaxConfig
                    traceDfMaxSubsetList[[traceDfPath]] = traceDfMaxConfig

                    i = i + 1   
                    
                }
            
            }

            # Find max of this param set
            traceDfMaxSubset = dplyr::bind_rows(traceDfMaxSubsetList)

            # Extract max per scenario
            paramDfMax = traceDfMaxSubset[traceDfMaxSubset$objective_func_val == max(traceDfMaxSubset$objective_func_val),]
            if(nrow(paramDfMax) > 1){
                stop("SAME PARAM VALS FOR BOTH!!")
            }
            
            optimalDfList[[as.character(i)]] = paramDfMax

        }

    }

    optimalDf = dplyr::bind_rows(optimalDfList)

    return(optimalDf)

}

#' @export
genSweepSurfacePlot = function(
    optimalDf,
    plotDir
){

    dir.create(plotDir, showWarnings = FALSE, recursive = TRUE)

    p = plotly::plot_ly() |> 
        plotly::add_trace(data = optimalDf,  x=~numSurveys, y=~detectionProb, z=~objective_func_val, type="mesh3d") |>
        plotly::add_trace(data = optimalDf, x=~numSurveys, y=~detectionProb, z=~objective_func_val, mode = "markers", type = "scatter3d", marker = list(size = 5, color = "red", symbol = 104))

    outPath = file.path(plotDir, "sweep_surface.html")
    htmlwidgets::saveWidget(p, outPath, selfcontained = T)

}

#' @export
genSimpleGridSf = function(
    sweepDir,
    polyDfPath,
    countryCode,
    outPath
){

    gridRes = 20

    coordsDfPath = file.path(sweepDir, "coordsDf.rds")
    traceDfPath = file.path(sweepDir, "traceDf.rds")

    # Read in poly defining extent
    polyDf = sf::read_sf(polyDfPath) |>
        dplyr::filter(GID_0==countryCode)
        
    polyExtent = sf::st_bbox(polyDf)

    # ---------------------------------
    # Pull out highest scoring iteration
    traceDf = readRDS(traceDfPath)

    traceDfMax = traceDf[traceDf$objective_func_val==max(traceDf$objective_func_val),]

    if(nrow(traceDfMax) > 1){
        traceDfMax = traceDfMax[traceDfMax$iteration == max(traceDfMax$iteration),]
    }

    coordsDf = readRDS(coordsDfPath) |>
        dplyr::filter(iteration == traceDfMax$iteration) |>
        sf::st_as_sf(coords=c("x", "y"), crs="WGS84")

    coordsDf$coord_id = paste0("point_", seq(1, nrow(coordsDf)))

    # Rasterise poly extent at given resolution
    gridDf = sf::st_make_grid(x=polyExtent, n=gridRes) |> 
        sf::st_sf()

    colnames(gridDf) = "geom"

    gridDf = cbind(POLY_ID=paste0("grid_", seq_len(nrow(gridDf))), gridDf)


    # Crop polys to intersect with target country / poly
    gridDfIntersect = sf::st_intersection(x=gridDf, y=polyDf) |>
        dplyr::select(POLY_ID, geom)

    # Calculate the number of survey points (coordsDf) per raster cell
    coordGridDf = sf::st_intersection(x = gridDfIntersect, y = coordsDf) |>
        sf::st_drop_geometry() |>
        dplyr::group_by(POLY_ID) |>
        dplyr::count()

    gridStatsDf = dplyr::left_join(gridDfIntersect, coordGridDf, by=c("POLY_ID"))

    gridStatsDf$n[is.na(gridStatsDf$n)] = 0

    # Calculate prop
    gridStatsDf$prop = gridStatsDf$n / sum(gridStatsDf$n)

    # Save
    sf::write_sf(gridStatsDf, outPath)

}

#' @export
plotSimpleGrid = function(
    simpleDfPath,
    targetCountryCode,
    optimalDfRow,
    plotPath
){  

    box::use(tmap[...])

    dir.create(dirname(plotPath), showWarnings = FALSE, recursive = TRUE)

    # Read in simple df
    simpleDf = sf::read_sf(simpleDfPath) |>
        dplyr::filter(prop > 0)

    # Read in country polys
    statePolysDf = sf::read_sf("../../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level1_africa.gpkg")

    countryPolysDf = sf::read_sf("../../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg")

    # Extent poly
    extentDf = countryPolysDf |>
        dplyr::filter(GID_0 == targetCountryCode)

    # Def title
    plotTitle = paste0("numSurveys: ", optimalDfRow$numSurveys, " | detectionProb: ", optimalDfRow$detectionProb, " | objFuncVal: ", round(optimalDfRow$objective_func_val, 2))

    p = tm_shape(statePolysDf, bbox = extentDf) + 
        tm_borders(lwd=0.2) +
        tm_shape(countryPolysDf, bbox = extentDf) + 
        tm_borders(lwd=0.8) +
        tm_shape(simpleDf) +
        tm_polygons(col="prop", alpha=0.8, title="") +
        tm_layout(
            legend.position=c("left", "bottom"),
            legend.frame=TRUE,
            legend.bg.color="grey",
            legend.bg.alpha=0.8,
            legend.text.size = 1.2,
            asp = 1,
            title = plotTitle
        )

    # p
    tmap_save(tm=p, filename = plotPath)

}

#' @export
genMontage = function(
    configSweepPath,
    optimalDfPath,
    plotDir
){

    box::use(utils[...])

    configSweepList = rjson::fromJSON(file=configSweepPath)

    optimalDf = read.csv(optimalDfPath)

    numSurveysVec = sort(configSweepList[["numSurveysVec"]])
    detectionProbVec = sort(configSweepList[["detectionProbVec"]])

    plotPathVec = c()
    for(numSurveys in numSurveysVec){

        for(detectionProb in detectionProbVec){

            x = optimalDf[optimalDf$numSurveys==numSurveys & optimalDf$detectionProb==detectionProb,]
            stopifnot(nrow(x)==1)
            
            plotPath = file.path(plotDir, "simple_grid/", paste0("simple_grid_sweep_", x$sweep_i, ".png"))
            
            stopifnot(file.exists(plotPath))
            
            plotPathVec = c(plotPathVec, plotPath)

        }

    }

    system(paste0("magick montage ", paste(plotPathVec, collapse=" "), " -geometry +", length(numSurveysVec), "+", length(detectionProbVec), " ", file.path(plotDir, "simple_grid_montage.png")))

}
