# -----------------------------------
# Cluster specific
# -----------------------------------
inputsKey = "cc_NGA_year_0"
inputsDir = here::here("surveillance/inputs/inf_rasters_processed", inputsKey, "outputs")

# Read in sumRasterPointsDf
sumRasterPointsDfPath = file.path(inputsDir, "sumRasterMaskPointsDf.csv")
sumRasterPointsDf = read.csv(sumRasterPointsDfPath)

# Create 5km poly around every point - assign all weighting of 1
# This generates a big list of polygons with a weighting - this can be generalised for 

sumRasterPointsDfSpatial = sumRasterPointsDf |>
    sf::st_as_sf(coords=c("x", "y"), crs="WGS84", remove=FALSE)

# Read in roads
roadsMask = raster::raster("../../inputs/masks/mask_roads_NGA_1000m_extent_NGA/mask.tif")
roadsMask[roadsMask==0] = NA

# Generate polygon version of roadsMask raster
roadsDf = raster::rasterToPolygons(roadsMask, dissolve = FALSE) |>
    sf::st_as_sf() |>
    sf::st_union() |>
    sf::st_sf()

sf::st_geometry(roadsDf) = "geom" # rename

# Buffer points by 5km
bufferRowList = list()
for(i in seq_len(nrow(sumRasterPointsDfSpatial))){
        
    print(i)
    
    # Buffer point
    bufferPoint = sf::st_buffer(sumRasterPointsDfSpatial[i,], dist=5000)
    intersectPoint = sf::st_intersection(x=roadsDf, y=bufferPoint)
    bufferRowList[[as.character(i)]] = intersectPoint
}

bufferDf = dplyr::bind_rows(bufferRowList)

sf::write_sf(bufferDf, "./data/intersection_real.gpkg")
