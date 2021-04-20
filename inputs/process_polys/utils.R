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
