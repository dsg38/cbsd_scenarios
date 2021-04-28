box::use(./utils)

polysDfPath = "../inputs_raw/polygons/polys_0/custom_poly_df.gpkg"
surveyDataPath = "../../../cbsd_landscape_model/input_generation/surveillance_data/raw_data/survey_data_summary.csv"
outDir = "../inputs_raw/survey_rasters/real_world/poly_stats/polys_0"

utils$calcPolySurveyDataStats(
    polysDfPath = polysDfPath,
    surveyDataPath = surveyDataPath,
    outDir = outDir
)
