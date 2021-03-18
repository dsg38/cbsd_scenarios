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
