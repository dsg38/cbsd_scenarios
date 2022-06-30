library(ggplot2)

outDir = "./plots"
dir.create(outDir, recursive = TRUE, showWarnings = FALSE)

# Get target keys
cumulativePassKeys = rjson::fromJSON(file="../output/cumulative_passKeys.json")
passKeys = cumulativePassKeys[["uga-RWA-BDI-drc_first_east-Pweto-zmb_regions_union-drc_north_central_field"]]

# Read in poly stats
polyDf = readRDS("../output/raster_poly_stats_agg_minimal_DONE.rds") |>
    dplyr::filter(simKey %in% passKeys) |>
    dplyr::filter(nchar(POLY_ID)==3)

polyDfSplitList = split(polyDf, polyDf$POLY_ID)

for(polyId in names(polyDfSplitList)){

    print(polyId)

    polyDfSubset = polyDfSplitList[[polyId]]

    # Extract the subset of sims that ever arrive in polyId
    simKeysAnyPos = unique(polyDfSubset[polyDfSubset$raster_num_fields > 0, "simKey"])

    dpcDfList = list()
    for(thisSimKey in simKeysAnyPos){

        polyDfAnyPos = polyDfSubset |>
            dplyr::filter(simKey==thisSimKey) |>
            dplyr::filter(raster_num_fields > 0) |>
            dplyr::arrange(raster_year) |>
            dplyr::mutate(year_standardised = (dplyr::row_number() - 1))
        
        dpcDfList[[thisSimKey]] = polyDfAnyPos

    }

    dpcDf = dplyr::bind_rows(dpcDfList)
    
    if(nrow(dpcDf) > 0){
        
        p = ggplot(dpcDf, aes(x=year_standardised, y=raster_prop_fields, colour=simKey)) +
            geom_line() +
            theme(legend.position="none") +
            ggtitle(polyId) +
            xlab("Years since CBSD arrival") +
            ylab("Proportion of fields infected") +
            ylim(0, 1) +
            xlim(0, 20)
        
        # p
        
        # Save
        outPath = file.path(outDir, paste0("dpc_", polyId, ".png"))
        ggsave(filename = outPath, plot=p)
    }


}
