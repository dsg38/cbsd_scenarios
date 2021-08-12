survey_df = sf::read_sf("./outputs/survey_locations/real/NGA-2017.gpkg")

raster_layer = raster::raster("./outputs/2021_03_26_cross_continental/rasters/2021_03_26_batch_0-job2-INF-2038.tif", crs="WGS84")
raster::crs(raster_layer) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 

# 
x = raster::extract(raster_layer, survey_df, cellnumbers=TRUE, df=TRUE)

# length(unique(x$cells))
# 
# raster::plot(raster_layer)
# raster::plot(survey_df, add=T)
y = raster_layer
y[] = 0

for(iRow in seq_len(nrow(x))){
    print(iRow)    
    thisRow = x[iRow,]
    
    y[thisRow$cells] = y[thisRow$cells] + 1
    
}

raster::writeRaster(y, "zil.tif")

mapview::mapview(y) + mapview::mapview(survey_df)

# raster::plot(y)
# raster::plot(survey_df, add=T)
