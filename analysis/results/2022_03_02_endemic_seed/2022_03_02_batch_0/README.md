# Stages of this analysis

## Process simulations to generate summary dfs

First, used `analysis/package_inf_rasters` to generate the `raster_poly_stats_agg.rds` summaries of the changing inf prop for different poly regions for each simulations rasters. Specifically:

1. `./config_inf_polys.json`: Create this json to describe which batch is being analysed / which polygons are stats going to be calculated for.
1. `./0_launch_slurm_gen_poly_stats.sh`: This file created a simualtion level summary using `./config_inf_polys.json` and `analysis/package_inf_rasters/gen_poly_stats.R` on the cluster.
1. `./1_aggregate_poly_stats.sh`: This file aggregates all the simulation level summaries using `analysis/package_inf_rasters/aggregate.R` and `./config_inf_polys.json`. NB: Also run on cluster. Output = `./data_simulations/raster_poly_stats_agg_minimal.rds`
1. `./2_summarise_inf_prop.sh`: 

## Analyse summary dfs to isolate sims that meet criteria


