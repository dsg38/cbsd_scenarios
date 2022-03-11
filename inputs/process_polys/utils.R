#' @export
calcPolyHostStats = function(
    polyDfIn,
    polyDfPathOut,
    hostRasterPath
){

    hostRaster = raster::raster(hostRasterPath)

    # Process to calc num fields
    polyHostNumFields = exactextractr::exact_extract(hostRaster, polyDfIn, fun='sum') * 1000

    polySumDf = cbind(polyDfIn, cassava_host_num_fields=polyHostNumFields)

    # Save
    sf::st_write(polySumDf, polyDfPathOut, overwrite=TRUE)
    
}


#' @export
calcPolySurveyDataStats = function(
    polysDfPath,
    surveyDataPath,
    outDir
){

    box::use(utils[...])
    box::use(ggplot2[...])

    plotDir = file.path(outDir, "plots")

    allPolysDf = sf::st_read(polysDfPath)

    surveyDataRaw = read.csv(surveyDataPath)
    surveyData = sf::st_as_sf(surveyDataRaw, coords = c("x","y"))
    sf::st_crs(surveyData) = "WGS84"

    dir.create(outDir, showWarnings=F, recursive=T)
    dir.create(plotDir, showWarnings = F, recursive=T)

    # -----
    inPolyCheckList = sf::st_intersects(allPolysDf, surveyData)

    for(iRow in seq_len(nrow(allPolysDf))){

        thisPoly = allPolysDf[iRow,]

        polyName = thisPoly$POLY_ID
        print(polyName)
        
        inPolyCheck = inPolyCheckList[[iRow]]
        
        if(length(inPolyCheck) > 0){
            
            inPolyDf = dplyr::slice(surveyData, inPolyCheck)
            
            polyYears = unique(inPolyDf$year)
            
            statDf = data.frame()
            for(thisYear in polyYears){
                        
                thisYearDf = inPolyDf[inPolyDf$year==thisYear,]
                
                nPos = sum(thisYearDf$cbsd)
                nTotal = nrow(thisYearDf)
                nNeg = nTotal - nPos
                propPos = nPos / nTotal
                
                thisRow = data.frame(
                    year=thisYear,
                    nPos=nPos,
                    nNeg=nNeg,
                    nTotal=nTotal,
                    propPos=propPos
                )
                
                statDf = rbind(statDf, thisRow)
                
            }
            
            ggplot(statDf, aes(x=year, y=propPos)) + 
                geom_line() + 
                geom_point() +
                ylim(0,1)
            
            plotPath = file.path(plotDir, paste0(polyName, ".png"))  
            ggsave(plotPath)
            
            statDfPath = file.path(outDir, paste0(polyName, ".csv"))
            write.csv(statDf, statDfPath, row.names = F)
            
        } else {
            
            print(paste0("Skipping - no survey points in poly: ", polyName))
            
        }

    }

}

numCellsPopulated = function(values, coverage_fractions){
    return(sum(values>0, na.rm = TRUE))
}

numCellsInPoly = function(values, coverage_fractions){
    return(length(values))
}

#' @export
appendHostStats = function(
    polyDfIn,
    hostRasterPath
){

    # Read in host raster
    hostRaster = raster::raster(hostRasterPath)

    # Calc num fields
    polyHostNumFields = exactextractr::exact_extract(hostRaster, polyDfIn, fun='sum') * 1000

    # Calc num cells populated
    polyNumCellsWithHost = exactextractr::exact_extract(hostRaster, polyDfIn, fun=numCellsPopulated)

    # Calc num cells total
    polyNumCellsInPoly = exactextractr::exact_extract(hostRaster, polyDfIn, fun=numCellsInPoly)

    # Calc land area km^2
    poly_area_km2 = as.numeric(units::set_units(sf::st_area(polyDfIn), km^2))

    # Build out df
    polySumDf = cbind(
        polyDfIn, 
        cassava_host_num_fields=polyHostNumFields,
        cassava_host_num_cells_with_host=polyNumCellsWithHost,
        cassava_host_num_cells_in_poly=polyNumCellsInPoly,
        poly_area_km2=poly_area_km2
    )

    return(polySumDf)

}

#' @export
mergeSplitPolys = function(
    splitPolyDir
){
    
    customPolyPaths = list.files(splitPolyDir, full.names = TRUE)

    polyList = list()
    for(customPolyPath in customPolyPaths){

        thisPolySp = readRDS(customPolyPath)
        thisPolySf = sf::st_as_sf(thisPolySp)
        
        polyName = tools::file_path_sans_ext(basename(customPolyPath))
        
        outRow = sf::st_sf(
            POLY_ID=polyName,
            geom=thisPolySf$geometry
        )
        
        polyList[[customPolyPath]] = outRow
    }

    polyDf = dplyr::bind_rows(polyList)

    return(polyDf)

}
