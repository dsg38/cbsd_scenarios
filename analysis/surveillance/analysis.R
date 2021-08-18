survey_df = readRDS("./temp/big.rds")

survey_df_split = split(survey_df, list(survey_df$batch, survey_df$job), drop=TRUE)

# thisSurveyDf = survey_df_split[[1]]

getDetectionYear = function(thisSurveyDf){
    
    arrival_year = min(thisSurveyDf$year)
    thisSurveyDfPos = thisSurveyDf[thisSurveyDf$num_positive_surveys > 0,]
    
    # Contingency for if no detection within num years being analysed
    if(nrow(thisSurveyDfPos)>0){
        detect_year = min(thisSurveyDfPos$year)
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

detectionYearDfList = pbapply::pblapply(survey_df_split, getDetectionYear)

detectionYearDf = dplyr::bind_rows(detectionYearDfList)

# TODO: Do I only look at 
hist(detectionYearDf$lag_years, breaks=seq(-0.5, 5.5, 1))
mean(detectionYearDf$lag_years)
