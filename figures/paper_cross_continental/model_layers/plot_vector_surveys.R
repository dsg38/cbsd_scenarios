box::use(tmap[...])

surveyDfWhitefly = sf::read_sf("../../../../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.gpkg") |>
    dplyr::filter(!is.na(adult_whitefly_mean))

# Load plotting layers
countryPolysDf = sf::read_sf("../../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg")
countryPolysDfSimple = sf::st_simplify(countryPolysDf, dTolerance = 1000)

oceanDf = sf::read_sf("../../data/ne_50m_ocean/ne_50m_ocean.shp")

# HACK: To get the extent to be the same as the other two plots
vectorRaster = raster::raster("../../../inputs/inputs_raw/vector/cassava_data-2022_02_09/vector.tif", crs="EPSG:4326")

# Calc the num surveys per country
surveyCountsDf = surveyDfWhitefly |>
    sf::st_drop_geometry() |>
    dplyr::count(country_code)

# x = surveyDfWhitefly |>
#     sf::st_drop_geometry() |>
#     dplyr::count(country_code, year)

print(sum(surveyCountsDf[surveyCountsDf$country_code!="UGA","n"]))

extent = c(
    xmin=-17.54167,
    ymin=-26.86667,
    xmax=45,
    ymax=15
)

# Plot whitefly data locations
p = tm_shape(vectorRaster, bbox=extent, raster.downsample=FALSE) +
    tm_raster(
        legend.show=FALSE,
        alpha=0
    ) +
    tm_shape(oceanDf, bbox=extent) +
    tm_fill(col="#A1C5FF") +
    tm_shape(countryPolysDfSimple) + 
    tm_polygons(alpha=0.5, lwd=0.5) +
    tm_shape(surveyDfWhitefly) + 
    tm_dots() +
    tm_compass(position = c("right", "top"), size=5) +
    tm_scale_bar(position = c("left", "bottom"), text.size = 1.2) +
    tm_graticules(lines = FALSE, labels.size=1.2)

tmap_save(p, "./plots/surveys_vector.png")
