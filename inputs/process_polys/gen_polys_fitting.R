box::use(./utils)
box::use(utils_epidem/utils_epidem)

# Get poly for UGA
ugaPolyDf = sf::read_sf("./gadm36_levels_gpkg/gadm36_level0_africa.gpkg") |>
    dplyr::filter(GID_0=="UGA")

# Read in Kampala custom poly
kamPolyDf = sf::read_sf("./custom_polys/mask_uga_kam.geojson")

# Gen uga hole using sf
ugaHoleDf = sf::st_difference(ugaPolyDf, kamPolyDf) |>
    dplyr::select(POLY_ID, geom) |>
    dplyr::rename(geometry=geom)

ugaHoleDf$POLY_ID = "mask_uga_hole"

# Gen grid polys using sf
gridRawDf = sf::read_sf("./custom_polys/mask_grids.geojson")

gridDf = sf::st_intersection(gridRawDf, ugaPolyDf) |>
    dplyr::select(POLY_ID, geometry)

# Merge
polyDf = dplyr::bind_rows(
    kamPolyDf,
    ugaHoleDf,
    gridDf
)

# Append host data
hostRasterPath = "../inputs_raw/host_landscape/CassavaMap/host.tif"

polyDfStats = utils$appendHostStats(
    polyDfIn=polyDf,
    hostRasterPath=hostRasterPath
)

# Save
outPath = "../inputs_raw/polygons/polys_fitting_host_CassavaMap.gpkg"
utils_epidem$write_sf(polyDfStats, outPath)


# Generate the sim survey target data
surveyDataPath = "../../../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.gpkg"
outDir = "../inputs_raw/survey_rasters/cassava_data-2022_02_09/poly_stats/polys_fitting"
ugaStatsBool = TRUE

utils$calcPolySurveyDataStats(
    polysDfPath = outPath,
    surveyDataPath = surveyDataPath,
    outDir = outDir,
    ugaStatsBool=ugaStatsBool
)



