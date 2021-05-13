surveyKeysList = rjson::fromJSON(file="./output/results_sim_survey.json")
infKeysList = rjson::fromJSON(file="./output/results_inf_polys.json")

names(surveyKeysList)
names(infKeysList)

surveyUgaKeys = intersect(surveyKeysList[["mask_uga_hole"]], surveyKeysList[["mask_uga_kam"]])


# surveyDrcNwKeys = surveyKeysList[["2017_mask_drc_nw"]]
# y = intersect(surveyUgaKeys, surveyDrcNwKeys)

# resList = list()

# Uga + inf NW
infDrcNwKeys = union(infKeysList[["2018-COD.23_1"]], infKeysList[["2018-COD.20_1"]])

ugaDrcNwKeys = intersect(surveyUgaKeys, infDrcNwKeys)


x = surveyKeysList[["2017_mask_drc_nw"]]
# intersect(x, surveyUgaKeys)


# resList[["survey_uga_inf_drc-nw"]] = ugaDrcNwKeys

# Inf DRC central small
ugaDrcCenSmallKeys = intersect(surveyUgaKeys, infKeysList[["2018-mask_drc_central_small"]])


# Survey drc central small
ugaSurveyDrcCenSmallKeys = intersect(surveyUgaKeys, surveyKeysList[["2017_mask_drc_central_small"]])

# Parse NGA arrival times
polysDf = readRDS("./output/raster_poly_stats_agg_minimal.rds")

polysDfNgaRaw = polysDf[polysDf$POLY_ID=="NGA",]

simKeys = paste(polysDfNgaRaw$scenario, polysDfNgaRaw$batch, polysDfNgaRaw$job, "0", sep="-")

polysDfNga = cbind(polysDfNgaRaw, simKey=simKeys)

getArrivalVec = function(
    polysDfNga, 
    title,
    matchKeys=NULL
    ){
    
    if(!is.null(matchKeys)){
        matchDf = polysDfNga[polysDfNga$simKey%in%matchKeys,]    
    }else{
        matchDf = polysDfNga
    }
    
    splitMatch = split(matchDf, matchDf$simKey)
    
    minYearVec = c()
    for(thisMatchDf in splitMatch){
        minYear = min(thisMatchDf[thisMatchDf$raster_num_fields > 0, "raster_year"])
        minYearVec = c(minYearVec, minYear)
        
    }
    
    propInf = round(sum(is.infinite(minYearVec)) / length(minYearVec), digits=3)
    meanVal = round(mean(minYearVec[!is.infinite(minYearVec)]), digits=1)
    
    fullTitle = paste0(title, " - propInf: ", propInf, " - len: ", length(minYearVec), " - avg: ", meanVal)
    
    hist(minYearVec, main=fullTitle, breaks=2020:2050)
    
    return(minYearVec)
}

getArrivalVec(
    polysDfNga=polysDfNga,
    title="all"
    
)

getArrivalVec(
    polysDfNga=polysDfNga,
    title="surveyUgaKeys",
    matchKeys=surveyUgaKeys
)

getArrivalVec(
    polysDfNga=polysDfNga,
    title="survey_uga_inf_drc-central-small",
    matchKeys=ugaDrcCenSmallKeys
)

getArrivalVec(
    polysDfNga=polysDfNga,
    title="survey_uga_survey_drc-central-small",
    matchKeys=ugaSurveyDrcCenSmallKeys
)


getArrivalVec(
    polysDfNga=polysDfNga,
    title="inf_drc-nw",
    matchKeys=infDrcNwKeys
)

getArrivalVec(
    polysDfNga=polysDfNga,
    title="survey_uga_inf_drc-nw",
    matchKeys=ugaDrcNwKeys
)



# getArrivalVec(
#     polysDfNga=polysDfNga,
#     title="drem",
#     matchKeys=x
# )
# 



