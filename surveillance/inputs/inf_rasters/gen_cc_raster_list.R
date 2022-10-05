# -------------------------
# For each of the target countries, generate the list of 
# target inf rasters for first and second year of arrival
# -------------------------

countryCodeVec = c("NGA", "CMR", "COG")
targetYearVec = c(0, 1)

simAnalysisDir = "../../../analysis/results/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/output/"
cumulativePassKeysPath = file.path(simAnalysisDir, "cumulative_passKeys.json")
polyDfPath = file.path(simAnalysisDir, "raster_poly_stats_agg_minimal_DONE.rds")

passKeysCode = "uga-RWA-BDI-drc_first_east-Pweto-zmb_regions_union-drc_north_central_field"

# Get target keys
cumulativePassKeys = rjson::fromJSON(file=cumulativePassKeysPath)
passKeys = cumulativePassKeys[[passKeysCode]]

# Read in poly stats
polyDf = readRDS(polyDfPath) |>
    dplyr::filter(simKey %in% passKeys)

# ---------------------------

for(thisCountryCode in countryCodeVec){

    polyDfCountryCode = polyDf |>
        dplyr::filter(POLY_ID == thisCountryCode) |>
        dplyr::filter(raster_num_fields > 0)

    # Append standardised years post arrival
    polyDfYearsNormList = list()
    for(thisSimKey in unique(polyDfCountryCode$simKey)){

        polyDfSimKey = polyDfCountryCode[polyDfCountryCode$simKey==thisSimKey,] |>
            dplyr::arrange(raster_year) |>
            dplyr::mutate(year_standardised = (dplyr::row_number() - 1))
        
        polyDfYearsNormList[[thisSimKey]] = polyDfSimKey

    }

    polyDfYearsNorm = dplyr::bind_rows(polyDfYearsNormList)

    # Extract subset for each target year
    for(thisTargetYear in targetYearVec){

        outDf = polyDfYearsNorm[polyDfYearsNorm$year_standardised==thisTargetYear,]
        
        outPath = file.path("./", paste0("cc_", thisCountryCode, "_year_", thisTargetYear), "polyDf.csv")
        
        # Save
        dir.create(dirname(outPath), showWarnings = FALSE, recursive = TRUE)
        
        print(outPath)
        print(nrow(outDf))
        write.csv(outDf, outPath, row.names = FALSE)
        
    }

}
