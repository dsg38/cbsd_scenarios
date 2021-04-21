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

        polyName = thisPoly$GID_0
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
            
            print(paste0("Skipping - no survey points in poly: ", thisPolyPath))
            
        }

    }

}

