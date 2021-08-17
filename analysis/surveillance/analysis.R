survey_df_raw = readRDS("./temp/big.rds")

# inf_raster_name = survey_df$inf_raster_name[[1]]

getJobBatch = function(inf_raster_name){
    splitList = strsplit(inf_raster_name, "-")[[1]]
    batch = splitList[[1]]
    job = splitList[[2]]
    year = as.numeric(tools::file_path_sans_ext(splitList[[4]]))
    
    outRow = data.frame(
        batch=batch,
        job=job,
        year
    )
    
    return(outRow)
}

job_batch_list = pbapply::pblapply(survey_df_raw$inf_raster_name, getJobBatch)

job_batch_cols = dplyr::bind_rows(job_batch_list)

survey_df = dplyr::bind_cols(job_batch_cols, survey_df_raw)

survey_df_split = split(survey_df, list(survey_df$batch, survey_df$job), drop=TRUE)

# thisSurveyDf = survey_df_split[[1]]

getDetectionYear = function(thisSurveyDf){
    
    arrival_year = min(thisSurveyDf$year)
    thisSurveyDfPos = thisSurveyDf[thisSurveyDf$num_positive_surveys > 0,]
    
    # TODO: Add in contingency for if no detection
    detect_year = min(thisSurveyDfPos$year)
    
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
