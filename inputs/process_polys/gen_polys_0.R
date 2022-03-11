box::use(./utils)

# Build gpkg with appended host stats
splitPolyDir = "./custom_polys/polys_0/"
hostRasterPath = "../inputs_raw/host_landscape/CassavaMap/host.tif"
polyDfPathOut = "../inputs_raw/polygons/polys_0_host_CassavaMap.gpkg"

polyDfMerged = utils$mergeSplitPolys(
    splitPolyDir=splitPolyDir
)

polyDfStats = utils$appendHostStats(
    polyDfIn=polyDfMerged,
    hostRasterPath=hostRasterPath
)

sf::write_sf(polyDfStats, polyDfPathOut)

# Generate the sim survey target data
surveyDataPath = "../../../cbsd_landscape_model/input_generation/surveillance_data/raw_data/survey_data_summary.csv"
outDir = "../inputs_raw/survey_rasters/real_world/poly_stats/polys_0"

utils$calcPolySurveyDataStats(
    polysDfPath = polyDfPathOut,
    surveyDataPath = surveyDataPath,
    outDir = outDir
)
