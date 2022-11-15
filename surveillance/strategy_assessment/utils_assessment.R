
#' @export
classifyRasterPointsDf = function(
    simpleGridDf,
    sumRasterPointsDf
){

    box::use(utils[...])

    # ---------------------------
    # Classify the sumRasterPointsDf according to the index of the simple grid df?
    # Purpose = to constrain the points selected to the road area

    sumRasterPointsDfSpatial = sf::st_as_sf(sumRasterPointsDf, coords=c("x", "y"), crs="WGS84")

    sf::sf_use_s2(FALSE)
    intersectionList = sf::st_intersects(sumRasterPointsDfSpatial, simpleGridDf)
    sf::sf_use_s2(TRUE)

    intersectionVec = c()
    for(x in intersectionList){
        if(length(x) != 1){ # i.e. presumably point not in any of the polys
            intersectionVec = c(intersectionVec, NA)
        }else{
            intersectionVec = c(intersectionVec, x)
        }
    }

    intersectionGridNames = simpleGridDf$POLY_ID[intersectionVec]
    
    sumRasterPointsDfGridNames = sumRasterPointsDf |>
        dplyr::mutate(POLY_ID = intersectionGridNames) |>
        dplyr::filter(!is.na(POLY_ID))

    # Save here
    # write.csv(sumRasterPointsDfGridNames, outPath, row.names = FALSE)

    return(sumRasterPointsDfGridNames)

}


#' @export
genWeightedRandomCoordsDf = function(
    simpleGridDf,
    sumRasterPointsDfGridNames,
    numSurveys
){

    # Sample from  sumRasterPointsDfGridNames proportional to the simpleGridDf prop column
    # So for each grid in simpleGridDf (where prop>0), 
    simpleGridDfAnyProp = simpleGridDf |>
        dplyr::filter(prop>0)

    coordsDfList = list()
    for(iRow in seq_len(nrow(simpleGridDfAnyProp))){
        
        thisRow = simpleGridDfAnyProp[iRow,]
        
        thisPolyId = thisRow$POLY_ID
        thisProp = thisRow$prop
        
        # Pull out subset of sumRasterPoints that fall in this mask
        sumRasterPointsDfSubset = sumRasterPointsDfGridNames[sumRasterPointsDfGridNames$POLY_ID==thisPolyId,]
        
        # Sample the proportion of points
        numSurveysSubset = round(numSurveys * thisProp)
        
        # We want to 'replace=TRUE' because we want to be able to allow the optimisation to try sampling the same place twice 
        coordsDfSubset = dplyr::sample_n(sumRasterPointsDfSubset, numSurveysSubset, replace = TRUE)
        
        coordsDfList[[thisPolyId]] = coordsDfSubset
        
    }

    coordsDf = dplyr::bind_rows(coordsDfList)

    return(coordsDf)

}
