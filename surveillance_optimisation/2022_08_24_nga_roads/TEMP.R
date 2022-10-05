x = read.csv("./data/dpcDf.csv")

# # Get target keys
# cumulativePassKeys = rjson::fromJSON(file="../../analysis/results/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/output/cumulative_passKeys.json")
# passKeys = cumulativePassKeys[["uga-RWA-BDI-drc_first_east-Pweto-zmb_regions_union-drc_north_central_field"]]
# 
# # Read in poly stats
# polyDf = readRDS("../../analysis/results/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/output/raster_poly_stats_agg_minimal_DONE.rds") |>
#     dplyr::filter(simKey %in% passKeys) |>
#     dplyr::filter(nchar(POLY_ID)==3)
# 
# x = polyDf |>
#     dplyr::filter(POLY_ID == "NGA") |>
#     dplyr::filter(raster_year == 2054)
# 
# 
# sum(x$raster_num_cells_populated > 0)
