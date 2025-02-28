simpleGridDf = sf::read_sf("./temp/simpleGridDf.gpkg")
sumRasterPointsDfGridNames = read.csv("./temp/sumRasterPointsDfGridNames.csv")
numSurveys = 250


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



mapview::mapview(thisRow)

x = simpleGridDf[simpleGridDf$POLY_ID %in% unique(sumRasterPointsDfGridNames$POLY_ID),]
mapview::mapview(x) + mapview::mapview(thisRow)

mapview::mapview(simpleGridDfAnyProp)

