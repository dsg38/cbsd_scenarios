#' @export
getArrivalVec = function(
    polysDfNga, 
    title,
    matchKeys=NULL
    ){

    box::use(utils[...])
    box::use(graphics[...])
    box::use(grDevices[...])

    if(!is.null(matchKeys)){
        matchDf = polysDfNga[polysDfNga$simKey%in%matchKeys,]    
    }else{
        matchDf = polysDfNga
    }
    
    splitMatch = split(matchDf, matchDf$simKey)
    
    minYearVec = c()
    for(thisMatchDf in splitMatch){
        minYear = suppressWarnings(min(thisMatchDf[thisMatchDf$raster_num_fields > 0, "raster_year"]))
        minYearVec = c(minYearVec, minYear)
        
    }
    
    propInf = round(sum(is.infinite(minYearVec)) / length(minYearVec), digits=3)
    meanVal = round(mean(minYearVec[!is.infinite(minYearVec)]), digits=1)
    
    fullTitle = paste0(title, " - propInf: ", propInf, " - len: ", length(minYearVec), " - avg: ", meanVal)
    
    png(filename=file.path("plots", paste0(title, ".png")), width=1000, height=1000)

    hist(minYearVec, main=fullTitle, breaks=2020:2050)
    dev.off()

}
