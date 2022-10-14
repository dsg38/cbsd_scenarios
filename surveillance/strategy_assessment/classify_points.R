simpleGridDfPath = "../results/2022_10_07_cc_NGA_year_0/data/simple_grid/simple_grid_sweep_80.gpkg"
outPath = "./data/sumRasterPointsDfGridNames.csv"

simpleGridDf = sf::read_sf(simpleGridDfPath)

inputsKey = "cc_NGA_year_0"
inputsDir = here::here("surveillance/inputs/inf_rasters_processed", inputsKey, "outputs")
sumRasterPointsDfPath = file.path(inputsDir, "sumRasterMaskPointsDf.csv")
sumRasterPointsDf = read.csv(sumRasterPointsDfPath)

# ---------------------------
# Classify the sumRasterPointsDf according to the index of the simple grid df?
# Purpose = to constrain the points selected to the road area

sumRasterPointsDfSpatial = sf::st_as_sf(sumRasterPointsDf, coords=c("x", "y"), crs="WGS84")

intersectionList = sf::st_intersects(sumRasterPointsDfSpatial, simpleGridDf)

intersectionVec = c()
for(x in intersectionList){
    if(length(x) != 1){ # i.e. presumably point not in any of the polys
        intersectionVec = c(intersectionVec, NA)
    }else{
        intersectionVec = c(intersectionVec, x)
    }
}

intersectionGridNames = simpleGridDf$POLY_ID[intersectionVec]
 
sumRasterPointsDfGridNames = sumRasterPointsDf |>
    dplyr::mutate(POLY_ID = intersectionGridNames) |>
    dplyr::filter(!is.na(POLY_ID))

# Save here
write.csv(sumRasterPointsDfGridNames, outPath, row.names = FALSE)
