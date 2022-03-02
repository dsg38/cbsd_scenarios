box::use(tmap[...])

# Define endemic country codes
endemicCountryCodes = c(
    "KEN",
    "TZA",
    "MOZ",
    "MWI"
)

# Read in survey points and extract CBSD positives
surveyDf = sf::read_sf("../../../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.gpkg") |>
    dplyr::filter(country_code %in% endemicCountryCodes) |>
    dplyr::filter(cbsd_any_bool==TRUE)

# Endemic poly
endemicDf = sf::read_sf("../../inputs/inputs_raw/init_conditions/endemic_seed/endemic_poly.gpkg")

# Extract points that intersect with endemic polys
iRowsInPoly = unlist(sf::st_intersects(endemicDf, surveyDf))

surveyDfSubset = surveyDf[iRowsInPoly,]

# Plot
countryDf = rnaturalearth::ne_download(scale = 10, type = 'countries', category = 'cultural', returnclass='sf') |>
    dplyr::filter(CONTINENT=="Africa")

extent = c(
    xmin=0,
    xmax=45,
    ymin=-30,
    ymax=7
)

tmap_options(check.and.fix = TRUE)
p = tm_shape(countryDf, bbox=extent) +
    tm_polygons(alpha=0.2) +
    tm_shape(endemicDf) + 
    tm_polygons("NAME", title="") +
    tm_shape(surveyDfSubset) + 
    tm_dots() +
    tm_graticules(lines = FALSE, labels.size=1.2) +
    tm_compass(position = c("right", "top"), size=5) + 
    tm_scale_bar(position = c("right", "bottom"), text.size = 1) +
    tm_layout(
        legend.text.size = 1.5
    )

# p

tmap_save(p, "endemic_seed.png")
