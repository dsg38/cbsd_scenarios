aggDfPaths = c(
    "../../simulations/sim_output/2021_03_26_cross_continental/2021_03_26_batch_0/raster_poly_stats_agg_minimal.rds",
    "../../simulations/sim_output/2021_03_26_cross_continental/2021_03_29_batch_0/raster_poly_stats_agg_minimal.rds"
)

outPath = "../results/2021_03_26_cross_continental/2021_04_29_merged/output/raster_poly_stats_agg_minimal.rds"

# --------------------------------------

outList = list()
for(thisPath in aggDfPaths){

    print(thisPath)

    outList[[thisPath]] = readRDS(thisPath)

}

saveRDS(dplyr::bind_rows(outList), outPath)
