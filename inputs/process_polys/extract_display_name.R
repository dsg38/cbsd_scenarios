dfPaths = list.files("../inputs_raw/polygons/", full.names = TRUE)

dfList = list()
for(dfPath in dfPaths){
    
    thisDf = sf::read_sf(dfPath)
    sf::st_geometry(thisDf) = NULL
    
    dfList[[dfPath]] = thisDf
    
}

countryFixList = list(
    "COD"="DRC",
    "CFA"="CAR",
    "COG"="Congo"
)

polyDf = unique(dplyr::bind_rows(dfList))

dispRowList = list()
for(iRow in seq_len(nrow(polyDf))){
    
    thisRow = polyDf[iRow,]
    
    # Pull out country
    POLY_ID = thisRow$POLY_ID
    NAME_0 = thisRow$NAME_0
    GID_0 = thisRow$GID_0
    NAME_1 = thisRow$NAME_1
    
    # Fix country
    if(!is.na(GID_0) & !is.na(NAME_0)){
        if(GID_0 %in% names(countryFixList)){
            NAME_0 = countryFixList[[GID_0]]
        }
    }
    
    display_name = NULL
    
    # If both names
    if(!is.na(NAME_0) & !is.na(NAME_1)){
        display_name = paste0(NAME_1, ", ", NAME_0)
    }
    # If only one
    else if(!is.na(NAME_0)){
        display_name = NAME_0
    }
    # If custom so only POLY_ID
    else{
        display_name = POLY_ID
    }
    
    outRow = data.frame(
        POLY_ID=POLY_ID,
        display_name
    )
    
    dispRowList[[as.character(iRow)]] = outRow
    
}

dispDf = dplyr::bind_rows(dispRowList)

write.csv(dispDf, "./outputs/poly_display_names.csv", row.names=FALSE)
