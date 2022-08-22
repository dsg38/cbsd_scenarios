box::use(utils_epidem/utils_epidem)

hostRasterPath = "../inputs/inputs_raw/host_landscape/CassavaMap-cassava_data-2022_02_09/host.tif"
surveyDfPath = "../../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.gpkg"
gridRes = 40
minNumFieldsPerPolyForHostStats = 1000
minNumSurveysPerPolyForWhiteflyStats = 10

# Build dataframe of four corner points of polygon

## Read in host landscape and convert to num fields
hostRaster = raster::raster(hostRasterPath) * 1000

hostExtent = sf::st_bbox(hostRaster)

## Build regular grid using host extent
gridDf = sf::st_make_grid(x=hostExtent, n=gridRes) |> 
    sf::st_sf()

colnames(gridDf) = "geom"

gridDf = cbind(POLY_ID=paste0("grid_", seq_len(nrow(gridDf))), gridDf)

# Calculate host landscape stats per polygon
gridDfHostStats = gridDf |>
    dplyr::mutate(area_km2=as.numeric(units::set_units(sf::st_area(geom), km^2))) |> # Calculate area and convert to km^2
    utils_epidem$appendHostStats(hostRasterPath = hostRasterPath) |> # Add some stats on cassava production 
    dplyr::mutate(fields_per_km2 = cassava_host_num_fields / area_km2) |>
    dplyr::filter(cassava_host_num_fields >= minNumFieldsPerPolyForHostStats) # Drop grids where 


# Calculate vector stats per poly
surveyDf = sf::read_sf(surveyDfPath) |>
    dplyr::filter(!is.na(adult_whitefly_mean))

whiteflyStatsDfList = list()
for(i in seq_len(nrow(gridDfHostStats))){
    
    print(i)
    
    thisGridDf = gridDfHostStats[i,]
    
    surveyDfGrid = sf::st_intersection(surveyDf, thisGridDf)
    
    whiteflyStatsDfList[[as.character(i)]] = data.frame(
        POLY_ID=thisGridDf$POLY_ID,
        num_surveys_in_grid=nrow(surveyDfGrid),
        adult_whitefly_mean=mean(surveyDfGrid$adult_whitefly_mean)
    )
    
}

whiteflyStatsDf = dplyr::bind_rows(whiteflyStatsDfList)

gridDfAllStats = dplyr::left_join(gridDfHostStats, whiteflyStatsDf, by="POLY_ID")

gridDfWhiteflyStats = gridDfAllStats |>
    dplyr::filter(num_surveys_in_grid >= minNumSurveysPerPolyForWhiteflyStats) |>
    dplyr::filter(adult_whitefly_mean > 0)

mapview::mapview(gridDfWhiteflyStats, z="adult_whitefly_mean", layer.name="-")
mapview::mapview(gridDfAllStats, z="fields_per_km2", layer.name="-")

