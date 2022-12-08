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
    
    ngaBool = thisSimDf[thisSimDf$POLY_ID=="NGA", "raster_prop_fields"] > 0
    cmrBool = thisSimDf[thisSimDf$POLY_ID=="CMR", "raster_prop_fields"] > 0
    cafBool = thisSimDf[thisSimDf$POLY_ID=="CAF", "raster_prop_fields"] > 0
    cogBool = thisSimDf[thisSimDf$POLY_ID=="COG", "raster_prop_fields"] > 0
    gabBool = thisSimDf[thisSimDf$POLY_ID=="GAB", "raster_prop_fields"] > 0
    civBool = thisSimDf[thisSimDf$POLY_ID=="CIV", "raster_prop_fields"] > 0

    outDf = data.frame(
        simKey = thisSimDf$simKey[[1]],
        numFieldsInf = numFieldsInf,
        ngaBool=ngaBool,
        cmrBool=cmrBool,
        cafBool=cafBool,
        cogBool=cogBool,
        gabBool=gabBool,
        civBool=civBool
    )
    
    return(outDf)
    
}

rankDfList = pbapply::pblapply(polyStatsDfList, FUN=genStats)

rankDf = dplyr::bind_rows(rankDfList) |>
    dplyr::arrange(numFieldsInf) |>
    dplyr::mutate(rank=seq(1, length(rankDfList)))

write.csv(rankDf, "./output/rankDf.csv", row.names = FALSE)
