box::use(dplyr[`%>%`])
box::use(./utils_survey)
# box::reload(utils_survey)

raster_survey_df = read.csv("./outputs/2021_03_26_cross_continental/survey_locations/host_real/survey_real/survey_scheme.csv")
host_raster_path = "./outputs/2021_03_26_cross_continental/host/host_real/host_num_fields.tif"
inf_raster_dir = "./outputs/2021_03_26_cross_continental/rasters_num_fields/"
year_mapping_df = read.csv("./outputs/2021_03_26_cross_continental/sim_subset/year_mapping.csv")

# ----------------------------------------------------------------

# Pre round the cells in the raster
# TODO: Migrate this into an earlier processing stage?
host_raster = utils_survey$gen_ceil_raster(host_raster_path)

inf_raster_paths = list.files(inf_raster_dir, recursive = TRUE, full.names = TRUE)

survey_df_list = pbapply::pblapply(
    inf_raster_paths, 
    FUN=utils_survey$do_full_survey, 
    host_raster=host_raster, 
    raster_survey_df=raster_survey_df
)

survey_df = dplyr::bind_rows(survey_df_list) %>%
    dplyr::left_join(year_mapping_df, by=c("batch", "job", "raster_year"))

# Add in false negative rate
false_neg_prob = 0.15

calcSurveyFalseNeg = function(
    survey_num_pos,
    false_neg_prob
){
    survey_num_pos_drop = sum(runif(n=survey_num_pos) > false_neg_prob)
    return(survey_num_pos_drop)
}

num_positive_surveys_0.15 = sapply(survey_df$num_positive_surveys_0.00, FUN=calcSurveyFalseNeg, false_neg_prob=false_neg_prob)

# Append
survey_df_out = dplyr::bind_cols(survey_df, num_positive_surveys_0.15=num_positive_surveys_0.15)

saveRDS(survey_df_out, "./outputs/2021_03_26_cross_continental/results/big.rds")
