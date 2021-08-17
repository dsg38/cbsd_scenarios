box::use(./utils_survey)
# box::reload(utils_survey)

raster_survey_df = read.csv("./outputs/survey_scheme.csv")
host_raster_path = "./outputs/2021_03_26_cross_continental/host/host_num_fields.tif"
inf_raster_dir = "./outputs/2021_03_26_cross_continental/rasters_num_fields/"

# ----------------------------------------------------------------

# Pre round the cells in the raster
# TODO: Migrate this into an earlier processing stage?
host_raster = utils_survey$gen_ceil_raster(host_raster_path)

inf_raster_paths = list.files(inf_raster_dir, recursive = TRUE, full.names = TRUE)

survey_df_list = pbapply::pblapply(inf_raster_paths, FUN=utils_survey$do_full_survey, host_raster=host_raster, raster_survey_df=raster_survey_df)

survey_df = dplyr::bind_rows(survey_df_list)

saveRDS(survey_df, "temp/big.rds")
