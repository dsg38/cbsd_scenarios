survey_df = readRDS("./outputs/2021_03_26_cross_continental/results/big.rds")

survey_df_split = split(survey_df, list(survey_df$batch, survey_df$job), drop=TRUE)

# thisSurveyDf = survey_df_split[[1]]

getDetectionYear = function(
    thisSurveyDf,
    num_positive_surveys_col
    ){
    
    arrival_year = min(thisSurveyDf$raster_year)
    thisSurveyDfPos = thisSurveyDf[thisSurveyDf[[num_positive_surveys_col]] > 0,]
    
    # Contingency for if no detection within num years being analysed
    if(nrow(thisSurveyDfPos)>0){
        detect_year = min(thisSurveyDfPos$raster_year)
    }else{
        detect_year = NA
    }
    
    outRow = data.frame(
        batch=thisSurveyDf$batch[[1]],
        job=thisSurveyDf$job[[1]],
        arrival_year=arrival_year,
        detect_year=detect_year,
        lag_years=detect_year-arrival_year
    )
    
    return(outRow)
    
}

plotHist = function(
    survey_df_split,
    getDetectionYear,
    num_positive_surveys_col,
    histTitle
){

    detectionYearDfList = pbapply::pblapply(survey_df_split, getDetectionYear, num_positive_surveys_col=num_positive_surveys_col)

    detectionYearDf = dplyr::bind_rows(detectionYearDfList)

    # TODO: What does the hist do if there's NAs due to no detection within alloted time?

    numNas = sum(is.na(detectionYearDf$lag_years))
    numNasStr = paste0("num NAs: ", numNas)

    histTitleFull = paste0(numNasStr, " - ", histTitle)
    
    hist(detectionYearDf$lag_years, breaks=seq(-0.5, 5.5, 1), main=histTitleFull)
    
    meanYears = mean(detectionYearDf$lag_years)

    return(meanYears)

}
    
# 
# write.csv(detectionYearDf, "./outputs/2021_03_26_cross_continental/results/detection_year.csv", row.names=FALSE)



mean_0 = plotHist(
    survey_df_split=survey_df_split,
    getDetectionYear=getDetectionYear,
    num_positive_surveys_col="num_positive_surveys_0_00",
    histTitle="Survey false negative = 0.00"
)

mean_0_15 = plotHist(
    survey_df_split=survey_df_split,
    getDetectionYear=getDetectionYear,
    num_positive_surveys_col="num_positive_surveys_0_15",
    histTitle="Survey false negative = 0.15"
)
