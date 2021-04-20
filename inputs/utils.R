#' @export
getExtentVecFromConfig = function(config){
                
    # Invalid if both null OR both not null
    extentNullBool = is.null(config[["cropExtent"]])
    codeNullBool = is.null(config[["cropByCountryCode"]])

    # Stop if both specified
    invalidConfig = (!extentNullBool & !codeNullBool)
    stopifnot(!invalidConfig)

    # If none specified, func returns NULL
    extentVec = NULL

    # Get extent
    if(!codeNullBool){
            
        countryCodeArray = config[["cropByCountryCode"]]
        extentVec = my::getCountryVecExtentVec(countryCodeArray)
            
    }else if(!extentNullBool){
            
        extentVec = unlist(config[["cropExtent"]])

    }

    return(extentVec)

}

#' @export
writeRasterCustom = function(rasterOut, pathOut, renameBool = FALSE){
        
    if(renameBool){
        pathOutTemp = gsub(".txt", ".asc", pathOut)
        
        raster::writeRaster(rasterOut, pathOutTemp, overwrite=TRUE)
        renameSuccessBool = file.rename(pathOutTemp, pathOut)
        
        stopifnot(renameSuccessBool)
            
    }else{
            
        raster::writeRaster(rasterOut, pathOut, overwrite=TRUE)
            
    }
    
        
}

#' @export
processRaster = function(rasterPath, extentVec, cropBool, pathOut, renameBool = FALSE){
        
    rasterIn = raster::raster(rasterPath)
    
    if(cropBool){
            rasterOut = raster::crop(rasterIn, extentVec)
    }else{
            rasterOut = rasterIn
    }
    
    writeRasterCustom(
        rasterOut = rasterOut,
        pathOut = pathOut,
        renameBool = renameBool
    )

    return(rasterOut)
}


# For a given raster, extract indexes with 0,0 corner (like simulator survey output)
extractIndex = function(thisRaster){
    
    box::use(dplyr[`%>%`])
    box::use(raster[...])

    zeroExtent = raster::extent(0, raster::xmax(thisRaster)-raster::xmin(thisRaster), 0, raster::ymax(thisRaster)-raster::ymin(thisRaster))
        
    raster::extent(thisRaster) = zeroExtent
    
    rasterIndexes = which(thisRaster[]>0)
    numRealSurveysInCell = thisRaster[rasterIndexes]
    indexDf = raster::as.data.frame(raster::rowColFromCell(thisRaster, rasterIndexes))
    indexDf = indexDf %>% dplyr::rename("X"="col", "Y"="row")
    
    indexDf = cbind(indexDf, numRealSurveysInCell)
    
    # Correct offset
    indexDf$X = indexDf$X - 1
    indexDf$Y = indexDf$Y - 1
    
    return(indexDf)
    
}

#' @export
genPolyIndex = function(
    surveyRasterDir,
    polyDfPath,
    outIndexDir
){

    box::use(utils[...])

    totalRasterPaths = list.files(surveyRasterDir, pattern="total", full.names=T)
    polyDf = sf::st_read(polyDfPath)

    for(thisTotalRasterPath in totalRasterPaths){
        
        print(thisTotalRasterPath)
        
        year = as.numeric(strsplit(basename(thisTotalRasterPath), "_")[[1]][[1]])
        
        thisRaster = raster::raster(thisTotalRasterPath)

        # For each mask
        for(iRow in seq_len(nrow(polyDf))){
                
            polyRow = polyDf[iRow,]
            
            thisPolygonStr = polyRow$GID_0
            print(thisPolygonStr)
            
            thisPolyRaster = raster::mask(thisRaster, polyRow, updateValue=0)
            thisPolyIndexDf = extractIndex(thisPolyRaster)

            outPolyIndexPath = file.path(outIndexDir, paste0(year, "_", thisPolygonStr, ".csv"))

            write.csv(thisPolyIndexDf, outPolyIndexPath, row.names = F)
                    
        }

    }

}
