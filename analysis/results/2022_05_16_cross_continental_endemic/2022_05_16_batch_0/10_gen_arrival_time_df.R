cumulativePassKeys = rjson::fromJSON(file="./output/cumulative_passKeys.json")
passKeys = cumulativePassKeys[["uga-RWA-BDI-drc_first_east-Pweto-zmb_regions_union-drc_north_central_field"]]


propYearDf = read.csv("./output/propYearDf.csv") |>
    dplyr::filter(simKey %in% passKeys) |>
    dplyr::mutate(sim_year = raster_year - 1)


thisPropInf = 0
propYearDfSubset = propYearDf |>
    dplyr::filter(prop==thisPropInf) |>
    dplyr::filter(nchar(POLY_ID)==3)

polySplitList = split(propYearDfSubset, propYearDfSubset$POLY_ID)

getMedian = function(thisDf){
    
    return(data.frame(
        POLY_ID=thisDf$POLY_ID[[1]],
        median=median(thisDf$raster_year)
    ))
    
    
}

medianArrivalDfList = lapply(polySplitList, getMedian)
medianArrivalDf = dplyr::bind_rows(medianArrivalDfList)

write.csv(medianArrivalDf, "./output/medianArrivalDf.csv", row.names = FALSE)
