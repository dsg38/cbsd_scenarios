roadsDfPath = "./data/buffer/groads_buffer_2000m.gpkg"

# Read in roads buffer
roadsDf = sf::read_sf(roadsDfPath)

# Read in survey data
surveyDf = sf::read_sf("../../../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.gpkg") |>  
    dplyr::filter(country_code=="NGA")

# How many NGA points in each FCLASS
intersectsList = sf::st_intersects(surveyDf, roadsDf)

pointDfList = list()
# For each point
for(i in seq_len(length(intersectsList))){
    
    print(i)
    
    # Get the rows of the roads that it intersects with
    roadsDfSubset = roadsDf[intersectsList[[i]],]
    roadsDfFclassVec = roadsDfSubset$FCLASS
    
    fclassList = list()
    fclassBoolList = list()
    for(FCLASS in sort(unique(roadsDf$FCLASS))){
        
        fclassList[paste0("FCLASS_", FCLASS)] = sum(roadsDfFclassVec==FCLASS)
        
        fclassBoolList[paste0("FCLASS_BOOL_", FCLASS)] = sum(roadsDfFclassVec==FCLASS) > 0
        
    }
    
    dfA = data.frame(
        i=i,
        merged_id=surveyDf[i,]$merged_id
    )
    
    dfB = data.frame(fclassList)
    
    dfC = data.frame(fclassBoolList)
    
    pointDfList[[as.character(i)]] = cbind(dfA, dfB, dfC, any_bool=any(dfC))

}

roadStatsDf = dplyr::bind_rows(pointDfList)

propAnyRoad = sum(roadStatsDf$any_bool) / nrow(surveyDf)


# ---------------------------------
# 

summaryStatsDfList = list()
for(FCLASS in sort(unique(roadsDf$FCLASS))){
    
    fclassBoolColname = paste0("FCLASS_BOOL_", FCLASS)
    bool_sum=sum(roadStatsDf[,fclassBoolColname])
    
    bool_sum_prop = bool_sum / nrow(surveyDf)
    
    summaryStatsDfList[[fclassBoolColname]] = data.frame(
        FCLASS=FCLASS,
        bool_sum=bool_sum
    )
}

fclassRoadStatsDf = dplyr::bind_rows(summaryStatsDfList) |>
    dplyr::mutate(prop=round(bool_sum / sum(bool_sum), 2))



# Where are points not near roads?
y = roadStatsDf[!roadStatsDf$any_bool,]$merged_id
surveyDfNoMatch = surveyDf |>
    dplyr::filter(merged_id %in% y)

# mapview::mapview(surveyDf)
mapview::mapview(surveyDfNoMatch)
