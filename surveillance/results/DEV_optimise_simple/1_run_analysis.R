box::use(../../strategy_assessment/utils_assessment)

# -----------------------------------
# Generalised poly based assessment
# -----------------------------------

polysDf = sf::read_sf("./data/intersection.gpkg")

inputsKey = "cc_NGA_year_0"

inputsDir = here::here("surveillance/inputs/inf_rasters_processed", inputsKey, "outputs")
infBrickPath = file.path(inputsDir, "brick.tif")
sumRasterPointsDfPath = file.path(inputsDir, "sumRasterMaskPointsDf.csv")



# Process sum inf raster centroid points to classify according to the POLY_ID of each simple grid cell
sumRasterPointsDfGridNames = utils_assessment$classifyRasterPointsDf(
    simpleGridDf = polysDf,
    sumRasterPointsDfPath = sumRasterPointsDfPath
)




numSurveys = 5
# ---------------------------

# Pick random set of 1000
startPolysDf = dplyr::sample_n(polysDf, numSurveys, replace = TRUE)


# Pick one random coord location per poly


# Now just the same as `doTrial` loop in `strategy_assessment/run_strategy.R`


