x = peakRAM::peakRAM({

    box::use(tictoc[...])

    tic(msg="total")

    args = commandArgs(trailingOnly=TRUE)

    configPath = args[[1]]
    jobIndex = args[[2]]

    # configPath = "./2021_03_26_cross_continental/config_poly.json"
    # jobIndex = 0

    # ---------------------------------
    config = rjson::fromJSON(file=configPath)

    # Job folder
    batchPath = here::here(config[["batchPath"]])
    polyDfPath = here::here(config[["polyDfPath"]])
    hostRasterPath = here::here(config[["hostRasterPath"]])

    # ---------------------------------

    jobDir = here::here(batchPath, paste0("job", jobIndex), "output/runfolder0")

    # Load polys
    polyDf = sf::read_sf(polyDfPath)

    # Read in host raster
    hostRaster = terra::rast(hostRasterPath)

    # List all rasters
    rasterPaths = list.files(jobDir, pattern="O_0_L_0_*_.*.000000.tif", full.names = T, recursive = T)
    # rasterPaths = rasterPaths[1:5]

    # Build raster stack
    rasterStack = terra::rast(rasterPaths)

    # Calculate num inf fields stack NB: for some reason, this loses the names in the stack
    tic(msg="multiply")
    rasterStackNumFieldsTerra = rasterStack * hostRaster * 1000
    toc()

    # Convert to raster stack for exactextractr
    rasterStackNumFields = raster::stack(rasterStackNumFieldsTerra)

    # Define func to work out num populated cells
    numCellsPopulated = function(values, coverage_fractions){
        return(sum(values>0, na.rm = TRUE))
    }

    # Calc poly stats for each raster
    tic(msg="extract")
    rasterDfList = list()
    for(i in seq_len(dim(rasterStackNumFields)[[3]])){

        thisRaster = rasterStackNumFields[[i]]
        rasterName = names(thisRaster)
        print(i)
        print(rasterName)

        # Sum within each polygon
        tic(msg="sum_loop")
        rasterPolySumDf = exactextractr::exact_extract(
            thisRaster,
            polyDf,
            'sum',
            stack_apply=TRUE,
            append_cols=c("POLY_ID")
        )
        
        rasterPolySumDf = dplyr::rename(rasterPolySumDf, "raster_num_fields" = 2)

        toc()

        # Calc num cells with any infection
        tic(msg="pop_loop")
        rasterPolyNumPopulatedDf = exactextractr::exact_extract(
            thisRaster, 
            polyDf, 
            fun=numCellsPopulated, 
            stack_apply=TRUE, 
            append_cols=c("POLY_ID")
        )

        rasterPolyNumPopulatedDf = dplyr::rename(rasterPolyNumPopulatedDf, "raster_num_cells_populated" = 2)

        toc()
        
        mergedDf = dplyr::full_join(rasterPolySumDf, rasterPolyNumPopulatedDf, by="POLY_ID")
        
        rasterDfList[[rasterName]] = mergedDf

    }
    toc()

    # Drop poly geom to speed up
    sf::st_geometry(polyDf) = NULL

    # For each raster = columns of extracted dfs
    dfList = list()
    for(rasterPath in rasterPaths){

        rasterPathNorm = normalizePath(rasterPath)
        print(rasterPathNorm)
        
        splitPath = strsplit(rasterPathNorm, "*/")[[1]]
        
        job = dplyr::nth(splitPath, -4)
        batch = dplyr::nth(splitPath, -5)
        scenario = dplyr::nth(splitPath, -6)
        
        # Get year
        rasterFilenameNoExt = tools::file_path_sans_ext(basename(rasterPathNorm))
        splitFilename = strsplit(rasterFilenameNoExt, "_")[[1]]
        raster_year = as.numeric(dplyr::last(splitFilename))
        raster_type = splitFilename[[5]]
            
        # Pull out corresponding raster stats df
        rasterStatsDf = rasterDfList[[rasterFilenameNoExt]]

        # Join by matching column
        rasterStatsPolyDfPartial = dplyr::full_join(polyDf, rasterStatsDf, by="POLY_ID")

        # Calc prop fields
        raster_prop_fields = rasterStatsPolyDfPartial$raster_num_fields / rasterStatsPolyDfPartial$cassava_host_num_fields
        raster_prop_fields[is.na(raster_prop_fields)] = 0
        
        rasterStatsPolyDf = cbind(rasterStatsPolyDfPartial, raster_prop_fields)
        
        # Build out df
        thisRasterDf = cbind(
            rasterStatsPolyDf,
            raster_year=raster_year,
            raster_type=raster_type,
            job=job,
            batch=batch,
            scenario=scenario,
            raster_path=rasterPathNorm
        )
        
        dfList[[rasterPathNorm]] = thisRasterDf
        
    }

    outDf = dplyr::bind_rows(dfList)

    outPath = here::here(jobDir, "raster_poly_stats.rds")
    print(outPath)

    saveRDS(outDf, outPath)

    toc()
})

print(x)
