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

# Buffer points by 5km
bufferRowList = list()
for(i in seq_len(nrow(sumRasterPointsDfSpatial))){
    print(i)
    
    bufferRowList[[as.character(i)]] = sf::st_buffer(sumRasterPointsDfSpatial[i,], dist=5000)
    
}

bufferDf = dplyr::bind_rows(bufferRowList)

sf::write_sf(bufferDf, "./data/bufferDf.gpkg")

# -------------------------------
