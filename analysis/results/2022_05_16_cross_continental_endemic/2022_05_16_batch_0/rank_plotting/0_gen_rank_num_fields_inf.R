library(ggplot2)

rasterYear = 2050

# -----------------------------------

polyStatsDfAll = readRDS("../output/raster_poly_stats_agg_minimal_DONE.rds")

passKeysAll  = rjson::fromJSON(file="../output/cumulative_passKeys.json")
constraintKey = "uga-RWA-BDI-drc_first_east-Pweto-zmb_regions_union-drc_north_central_field"

passKeys = passKeysAll[[constraintKey]]

polyIdAll = unique(polyStatsDfAll$POLY_ID)

polyIdTarget = polyIdAll[nchar(polyIdAll)==3]

# --------------------------------------
# Pull out rasterYear rows and sort by num fields infected in all polys
polyStatsDf = polyStatsDfAll |>
    dplyr::filter(simKey %in% passKeys & POLY_ID %in% polyIdTarget & raster_year == rasterYear)


polyStatsDfList = split(polyStatsDf, polyStatsDf$simKey)

genStats = function(thisSimDf){
    
    numFieldsInf = sum(thisSimDf$raster_num_fields)
    
    ngaBool = thisSimDf[thisSimDf$POLY_ID=="NGA", "raster_prop_fields"] > 0.01

    # browser()
    
    outDf = data.frame(
        simKey = thisSimDf$simKey[[1]],
        numFieldsInf = numFieldsInf,
        ngaBool=ngaBool
    )
    
    return(outDf)
    
}

rankDfList = pbapply::pblapply(polyStatsDfList, FUN=genStats)

rankDf = dplyr::bind_rows(rankDfList) |>
    dplyr::arrange(numFieldsInf) |>
    dplyr::mutate(rank=seq(1, length(rankDfList)))

# p = ggplot(rankDf, aes(numFieldsInf, fill=ngaBool)) + 
#     geom_histogram() +
#     xlim(0, max(rankDf$numFieldsInf))
# p
write.csv(rankDf, "./output/rankDf.csv", row.names = FALSE)




