# Read in survey points and endemic region polygon
surveyDf = sf::read_sf("../../../../../cassava_data/data_merged/data/2021_10_01/cassava_data_minimal.gpkg")
endemicPolyDf = sf::read_sf("./endemic.geojson")

# Which points are in endemic poly
iRowsInPoly = unlist(sf::st_intersects(endemicPolyDf, surveyDf))

# Extract points in endemic poly that are also CBSD positive
surveyDfSubset = surveyDf[iRowsInPoly,] |>
    dplyr::filter(cbsd_any_bool==TRUE)

# Read in template raster
hostRasterRaw = raster::raster("../../host_landscape/default/host.tif")
hostRaster = hostRasterRaw * 1000

surveyRaster = raster::rasterize(x=surveyDfSubset, y=hostRaster, field=1, fun="sum", background=0)

# Is there the same or greater number of host fields than surveys in each cell?
surveyBool = surveyRaster[]>0
surveyIndex = which(surveyBool)
surveyVals = surveyRaster[][surveyBool]

hostValsRaw = hostRaster[][surveyBool]
hostValsCeil = ceiling(hostValsRaw)

# Isolate cells where num surveys exceeds number of host
problemDf = data.frame(
    surveyIndex,
    surveyVals,
    hostValsRaw,
    hostValsCeil
) |> 
    dplyr::mutate(problemBool = surveyVals>hostValsCeil) |>
    dplyr::filter(problemBool==TRUE)


# Fix surveyRaster
for(iRow in seq_len(nrow(problemDf))){
    
    thisRow = problemDf[iRow,]
    
    surveyRaster[thisRow$surveyIndex] = thisRow$hostValsCeil
    
}

# Convert survey raster to inf / sus rasters 
# NB: This is surveyRaster (num fields to survey) divided by hostRaster (num fields abs)
# resulting in the proportion of the host raster to contain infected fields
infRasterProp = surveyRaster / hostRaster
infRasterProp[is.na(infRasterProp)] = 0

# Because I ceiled the host, this sets any that exceeded the max possible proportion (1) to 1
infRasterProp[infRasterProp>1] = 1

# Generate sus + rem raster
susRasterProp = 1 - infRasterProp

remRasterProp = susRasterProp
remRasterProp[] = 0

# Save
raster::writeRaster(infRasterProp, "./inf_raster.tif")
raster::writeRaster(susRasterProp, "./sus_raster.tif")
raster::writeRaster(remRasterProp, "./rem_raster.tif")
