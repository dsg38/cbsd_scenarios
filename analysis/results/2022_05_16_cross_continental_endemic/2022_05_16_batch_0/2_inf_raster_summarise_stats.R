library(ggplot2)

summariseInfStats = function(statsDfPath, outPath){

    summaryDfRowsList = list()

    statsDf = readRDS(statsDfPath)

    targetRasterYearDf = read.csv("./config/inf_target_years.csv") |>
        dplyr::filter(POLY_ID != "kampala")

    resList = list()
    for(iRow in seq_len(nrow(targetRasterYearDf))){
        
        thisRow = targetRasterYearDf[iRow,]
        maskName = thisRow$POLY_ID
        year = thisRow$raster_year_target
        
        print(maskName)
        
        statsDfSubset = statsDf[statsDf$POLY_ID==maskName & statsDf$raster_year==year,]

        anyInfJobsDf = statsDfSubset[statsDfSubset$raster_num_fields > 0,]

        passKeys = anyInfJobsDf$simKey

        # print(length(passKeys))
        # browser()
        # print(length(passKeys) / nrow(statsDfSubset))

        resList[[maskName]] = passKeys

        summaryDfRowsList[[maskName]] = data.frame(
            maskName=maskName,
            nPass=length(passKeys),
            propPass=length(passKeys) / nrow(statsDfSubset)
        )
    }

    outJson = rjson::toJSON(resList, indent=4)

    readr::write_file(outJson, outPath)

    summaryDf = dplyr::bind_rows(summaryDfRowsList)

}

# --------------------------------------
# Extract simKeys for sims that have any infection in a given poly by the target year

# All jobs
statsDfPath = "./output/raster_poly_stats_agg_minimal.rds"
outPath = "./output/results_inf_polys.json"

summaryDfAll = summariseInfStats(
    statsDfPath=statsDfPath,
    outPath=outPath
) |>
    dplyr::bind_cols(cat="all")

# Just complete
statsDfPathDone = "./output/raster_poly_stats_agg_minimal_DONE.rds"
outPathDone = "./output/results_inf_polys_DONE.json"

summaryDfDone = summariseInfStats(
    statsDfPath=statsDfPathDone,
    outPath=outPathDone
) |>
    dplyr::bind_cols(cat="done")

# Complete up to present day
statsDfPathPresentDay = "./output/raster_poly_stats_agg_minimal_PRESENTDAY.rds"
outPathPresentDay = "./output/results_inf_polys_PRESENTDAY.json"

summaryDfPresentDay = summariseInfStats(
    statsDfPath=statsDfPathPresentDay,
    outPath=outPathPresentDay
) |>
    dplyr::bind_cols(cat="presentday")

summaryDf = dplyr::bind_rows(
    summaryDfAll,
    summaryDfDone,
    summaryDfPresentDay
)

# p = ggplot(summaryDf, aes(x=maskName, y=propPass, col=cat)) + 
#     geom_point() +
#     ylim(0,1)
# p
