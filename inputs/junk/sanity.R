box::use(./utils)

# Check if all polygons fall within survey raster extent

configPath = "inputs_scenarios/2021_03_17_cross_continental/config.json"
surveyPolysDfPath = file.path("inputs_raw/polygons/polys_0/custom_poly_df.gpkg")

# ---------------------------------------------------------

config = my::readJsonFile(configPath)

polyDf = sf::st_read(surveyPolysDfPath)

extentVec = utils$getExtentVecFromConfig(config)
# extentVec[['xmax']] = 32.38

# Build extent poly
extentPolygonDfSt = data.frame(
    lat=c(extentVec[["ymax"]], extentVec[["ymax"]], extentVec[["ymin"]], extentVec[["ymin"]]),
    lng=c(extentVec[["xmin"]], extentVec[["xmax"]], extentVec[["xmax"]], extentVec[["xmin"]]),
    id=c("A", "B", "C", "D"),
    row.names = NULL
)

extentPolygonDf = sfheaders::sf_polygon(extentPolygonDfSt, x = "lng", y = "lat", keep = TRUE)

sf::st_crs(extentPolygonDf) = "WGS84"

# Check if contains

checkPolysInExtent = function(
    surveyPolysDfPath,
    extentPolygonDf
){

    polyDf = sf::st_read(surveyPolysDfPath)
    polysInExtentBool = all(sf::st_covered_by(polyDf, extentPolygonDf, sparse=FALSE))

    return(polysInExtentBool)

}



plot(sf::st_geometry(extentPolygonDf))
plot(sf::st_geometry(polyDf), add=T)
