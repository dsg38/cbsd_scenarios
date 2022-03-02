# Define endemic country codes
endemicCountryCoastalCodes = c(
    "KEN",
    "TZA",
    "MOZ"
)

endemicCountryCodes = c(
    endemicCountryCoastalCodes,
    "MWI"
)

# Read in survey points and extract CBSD positives
surveyDf = sf::read_sf("../../../../../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.gpkg") |>
    dplyr::filter(country_code %in% endemicCountryCodes) |>
    dplyr::filter(cbsd_any_bool==TRUE)

# Download ocean polys
oceanDf = rnaturalearth::ne_download(scale = 10, type = 'ocean', category = 'physical', returnclass='sf')

# Buffer ocean by 1dd (approx 110km)
sf::sf_use_s2(FALSE)
oceanDfBuffer = sf::st_buffer(x=oceanDf, dist=2)

# Intersect coastal endemic countries with with oceanBuffer & Glue in MWI
countryDf = rnaturalearth::ne_download(scale = 10, type = 'countries', category = 'cultural', returnclass='sf') 

coastalCountryDf = countryDf |>
    dplyr::filter(ADM0_A3%in%endemicCountryCoastalCodes)

mwiDf = countryDf |>
    dplyr::filter(ADM0_A3=="MWI")

endemicDf = sf::st_intersection(x=oceanDfBuffer, y=coastalCountryDf) |>
    dplyr::bind_rows(mwiDf)|>
    dplyr::select(SOV_A3, geometry)

# Save the buffer polygon for plotting etc.
sf::write_sf(endemicDf, "./endemic_poly.gpkg", overwrite=TRUE) 
    
# Extract points that intersect with endemic polys
iRowsInPoly = unlist(sf::st_intersects(endemicDf, surveyDf))

surveyDfSubset = surveyDf[iRowsInPoly,]

# Read in template raster
hostRasterRaw = raster::raster("../../host_landscape/CassavaMap-cassava_data-2022_02_09/host.tif")
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
