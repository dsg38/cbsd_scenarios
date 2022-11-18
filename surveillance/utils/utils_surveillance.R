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

    startIndex = 0
    if("startIndex" %in% names(configSweepList)){
        startIndex = configSweepList[["startIndex"]]
    }

    # Build configs
    for(numSurveys in numSurveysVec){

        for(detectionProb in detectionProbVec){

            for(step in stepVec){
                
                for(initTemp in initTempVec){
                    
                    print(startIndex)
                    
                    thisDir = file.path(topDir, paste0("sweep_", startIndex))
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
                    
                    startIndex = startIndex + 1   
                    
                }
            
            }

        }

    }
    
}

#' @export
genSweepOptimalDf = function(configSweepPath){

    # Define output dir
    topDir = file.path(dirname(configSweepPath), "sweep")

    # Loop over all traceDfs and extract the one row representing the highest value for that sim
    traceDfPathList = list.files(path=topDir, pattern="traceDf.rds", recursive = TRUE, full.names = TRUE)

    traceDfAllList = list()
    for(traceDfPath in traceDfPathList){
        
        print(traceDfPath)

        traceDf = readRDS(traceDfPath) |>
            dplyr::mutate(sweep_i = as.numeric(stringr::str_split(basename(dirname(dirname(traceDfPath))), "_")[[1]][[2]]))
        
        # Extract max
        traceDfMax = traceDf[traceDf$objective_func_val == max(traceDf$objective_func_val),]
        
        if(nrow(traceDfMax) > 1){
            traceDfMax = traceDfMax[traceDfMax$iteration==max(traceDfMax$iteration),]
        }
        
        # Read in config
        configPath = file.path(dirname(dirname(traceDfPath)), "config.json")
        configList = rjson::fromJSON(file=configPath)
        
        configDf = data.frame(configList)
        
        traceDfMaxConfig = cbind(traceDfMax, configDf)
        
        traceDfAllList[[traceDfPath]] = traceDfMaxConfig


    }

    traceDfAll = dplyr::bind_rows(traceDfAllList)

    # Loop over numSurveys and detectionProb and pull out single row that has max objVal
    numSurveysVec = sort(unique(traceDfAll$numSurveys))
    detectionProbVec = sort(unique(traceDfAll$detectionProb))

    optimalDfList = list()
    i = 0
    for(numSurveys in numSurveysVec){
        
        for(detectionProb in detectionProbVec){
            
            traceDfAllSubset = traceDfAll[traceDfAll$numSurveys==numSurveys & traceDfAll$detectionProb == detectionProb,]
            
            # Extract max per scenario
            optimalDfRow = traceDfAllSubset[traceDfAllSubset$objective_func_val == max(traceDfAllSubset$objective_func_val),]
            
            if(nrow(optimalDfRow) > 1){
                optimalDfRow = optimalDfRow[optimalDfRow$iteration==max(optimalDfRow$iteration),]
            }
            
            optimalDfList[[as.character(i)]] = optimalDfRow
            
            i = i + 1
            
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
    gridDf = sf::st_make_grid(x=polyExtent, cellsize=0.5) |> 
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
genSimpleClustersSf = function(
    sweepDir,
    outPath
){

    coordsDfPath = file.path(sweepDir, "coordsDf.rds")
    traceDfPath = file.path(sweepDir, "traceDf.rds")

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

    # --------------------------------------------------------------

    # Buffer points by 5km
    bufferDf = sf::st_buffer(coordsDf, dist=5000) |>
        sf::st_union() |>
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
    sf::write_sf(gridStatsDf, outPath)

}

#' @export
plotSimpleGrid = function(
    simpleDfPath,
    extentBbox,
    optimalDfRow,
    breaks,
    legendPos,
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

    # Def title
    plotTitle = paste0("numSurveys: ", optimalDfRow$numSurveys, " | detectionProb: ", optimalDfRow$detectionProb, " | objFuncVal: ", round(optimalDfRow$objective_func_val, 2))

    # Check that plotting range covers all vals
    stopifnot(all(simpleDf$prop<=max(breaks)))

    p = tm_shape(statePolysDf, bbox = extentBbox) + 
        tm_borders(lwd=0.2) +
        tm_shape(countryPolysDf, bbox = extentBbox) + 
        tm_borders(lwd=0.8) +
        tm_shape(simpleDf) +
        tm_polygons(
            col="prop", 
            alpha=0.8, 
            title="",
            breaks=breaks,
            style="cont"
        ) +
        tm_layout(
            legend.position=legendPos,
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
    individualPlotsDir,
    outPlotPath
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
            
            plotPath = file.path(individualPlotsDir, paste0("sweep_", x$sweep_i, ".png"))
            
            stopifnot(file.exists(plotPath))
            
            plotPathVec = c(plotPathVec, plotPath)

        }

    }

    dir.create(dirname(outPlotPath), showWarnings = FALSE, recursive = TRUE)

    system(paste0("magick montage ", paste(plotPathVec, collapse=" "), " -geometry +", length(numSurveysVec), "+", length(detectionProbVec), " -tile ", length(detectionProbVec), "x", length(numSurveysVec), " ", outPlotPath))

}
