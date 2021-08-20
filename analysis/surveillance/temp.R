box::use(dplyr[`%>%`])

# detectionDf = read.csv("./outputs//2021_03_26_cross_continental/results/detection_year.csv")

oldDf = readRDS("./outputs/2021_03_26_cross_continental/results/big_nearest.rds")



# year_mapping_df = read.csv("./outputs/2021_03_26_cross_continental/sim_subset/year_mapping.csv")

survey_df = oldDf %>%
    dplyr::rename(num_positive_surveys_0_00=num_positive_surveys)

calcSurveyFalseNeg = function(
    survey_num_pos,
    false_neg_prob
){
    survey_num_pos_drop = sum(runif(n=survey_num_pos) > false_neg_prob)
    return(survey_num_pos_drop)
}

num_positive_surveys_0_15 = sapply(survey_df$num_positive_surveys_0_00, FUN=calcSurveyFalseNeg, false_neg_prob=0.15)

num_positive_surveys_0_30 = sapply(survey_df$num_positive_surveys_0_00, FUN=calcSurveyFalseNeg, false_neg_prob=0.3)

outDf = dplyr::bind_cols(survey_df, 
    num_positive_surveys_0_15=num_positive_surveys_0_15,
    num_positive_surveys_0_30=num_positive_surveys_0_30

)

saveRDS(outDf, "./outputs/2021_03_26_cross_continental/results/big.rds")
