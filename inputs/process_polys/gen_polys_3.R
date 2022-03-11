box::use(./utils)

# Bind polys_0 output to polys_1
polys_0_df = sf::read_sf("../inputs_raw/polygons/polys_0_host_CassavaMap.gpkg")

# mapview::mapview(polys_0_df)
hostRasterPath = "../inputs_raw/host_landscape/CassavaMap/host.tif"

africaDfPath = "./gadm36_levels_gpkg/gadm36_level1_africa.gpkg"
africaDf = sf::read_sf(africaDfPath)

africaDfSubset = africaDf[africaDf$GID_0 %in% c("ZMB", "COD"),]

africaDfHost = utils$appendHostStats(
    polyDfIn=africaDfSubset,
    hostRasterPath=hostRasterPath
)

# Append POLY_ID col
africaDfHostId = cbind(
    POLY_ID=africaDfHost$GID_1,
    africaDfHost
)

outDf = dplyr::bind_rows(
    polys_0_df,
    africaDfHostId
)

polyDfPathOut = "../inputs_raw/polygons/polys_3_host_CassavaMap.gpkg"
sf::write_sf(outDf, polyDfPathOut)

# Generate the sim survey target data
surveyDataPath = "../../../cbsd_landscape_model/input_generation/surveillance_data/raw_data/survey_data_summary.csv"
outDir = "../inputs_raw/survey_rasters/real_world/poly_stats/polys_3"

utils$calcPolySurveyDataStats(
    polysDfPath = polyDfPathOut,
    surveyDataPath = surveyDataPath,
    outDir = outDir
)
