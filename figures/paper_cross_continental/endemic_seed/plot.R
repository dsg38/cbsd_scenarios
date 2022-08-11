box::use(tmap[...])
box::use(utils_epidem/utils_epidem)

# Define endemic country codes
endemicCountryCodes = c(
    "KEN",
    "TZA",
    "MOZ",
    "MWI"
)

# Read in survey points and extract CBSD positives
surveyDf = sf::read_sf("../../../../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.gpkg") |>
    dplyr::filter(country_code %in% endemicCountryCodes) |>
    dplyr::filter(cbsd_any_bool==TRUE)

# Endemic poly
endemicDf = sf::read_sf("../../../inputs/inputs_raw/init_conditions/endemic_seed/endemic_poly.gpkg")

# Extract points that intersect with endemic polys
iRowsInPoly = unlist(sf::st_intersects(endemicDf, surveyDf))

surveyDfSubset = surveyDf[iRowsInPoly,]

# Plot
countryDf = rnaturalearth::ne_download(scale = 10, type = 'countries', category = 'cultural', returnclass='sf') |>
    dplyr::filter(CONTINENT=="Africa")

extent = utils_epidem$get_extent_country_code_vec(c("MOZ", "COD", "KEN"))

oceanDf = sf::read_sf("../../data/ne_50m_ocean/ne_50m_ocean.shp")

tmap_options(check.and.fix = TRUE)
p = tm_shape(countryDf, bbox=extent) +
    tm_polygons(alpha=0.2) +
    tm_shape(oceanDf, bbox=extent) +
    tm_fill(col="#A1C5FF", alpha=0.6) +
    tm_shape(endemicDf) + 
    tm_polygons("NAME", title="") +
    tm_shape(surveyDfSubset) + 
    tm_dots() +
    tm_compass(position = c("right", "top"), size=5) +
    tm_scale_bar(position = c("right", "bottom"), text.size = 1.2) +
    tm_graticules(lines = FALSE, labels.size=1.2) +
    tm_layout(
        legend.position=c("left", "bottom"),
        legend.frame=TRUE,
        legend.bg.color="grey",
        legend.bg.alpha=0.8,
        legend.text.size = 1.2
    )

# p

tmap_save(p, "endemic_seed.png")
