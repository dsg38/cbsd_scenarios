box::use(tmap[...])

# -------------------
# What is the average survey data inf prop in the endemic polygons?
# -------------------

# Define endemic country codes
endemicCountryCodes = c(
    "KEN",
    "TZA",
    "MOZ",
    "MWI"
)

# Read in survey points and drop cbsd NAs
surveyDf = sf::read_sf("../../../../../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.gpkg") |>
    dplyr::filter(country_code %in% endemicCountryCodes) |>
    dplyr::filter(!is.na(cbsd_any_bool))

# Endemic poly
endemicDf = sf::read_sf("../../../../inputs/inputs_raw/init_conditions/endemic_seed/endemic_poly.gpkg")

# Extract points that intersect with endemic polys
iRowsInPoly = unlist(sf::st_intersects(endemicDf, surveyDf))

surveyDfSubset = surveyDf[iRowsInPoly,]

# Calc inf prop for each country
countryCodes = unique(surveyDfSubset$country_code)

outList = list()
for(thisCountryCode in countryCodes){
    
    thisDf = surveyDfSubset[surveyDfSubset$country_code==thisCountryCode,]
    infProp = sum(thisDf$cbsd_any_bool) / nrow(thisDf)
    
    outList[[thisCountryCode]] = data.frame(
        thisCountryCode,
        infProp
    )
    
}

statsDf = dplyr::bind_rows(outList)
mean(statsDf$infProp) #56%
