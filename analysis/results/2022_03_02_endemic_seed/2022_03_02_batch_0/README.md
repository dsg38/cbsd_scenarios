# Stages of this analysis

## Justification for 50% criteria

`./stats_survey_inf_prop.R`: Calcualates the infectious proportion of survey points in the endemic polys. Avg across all of them is ~56%.

## Process simulations to generate summary dfs

First, used `analysis/package_inf_rasters` to generate the `raster_poly_stats_agg.rds` summaries of the changing inf prop for different poly regions for each simulations rasters. Specifically:

- `./config_inf_polys.json`: Manually create this json to describe which batch is being analysed / which polygons are stats going to be calculated for.
- `./0_launch_slurm_gen_poly_stats.sh`: This file created a simualtion level summary using `./config_inf_polys.json` and `analysis/package_inf_rasters/gen_poly_stats.R` on the cluster.
- `./1_aggregate_poly_stats.sh`: This file aggregates all the simulation level summaries using `analysis/package_inf_rasters/aggregate.R` and `./config_inf_polys.json`. NB: Also run on cluster. Output = `./data_simulations/raster_poly_stats_agg_minimal.rds`
- `./2_summarise_inf_prop.sh`: Summarise year in which, for each sim, the epidemic within a given polygon exceeds a given inf prop thresehold. Output = `./data_simulations/propYearDf.csv`

## Analyse summary dfs to isolate sims that meet criteria

- `./3_select_endemic_inf.R`: Isolate sims which, prior to sim end state of 20 years, don't exceed 1% in non-endemic countries but exceed 50% in all endemic region polygons. Then, randomly pick one of these sims, whose end state will be used for the endemic inf prop. Output = `results/rand_job.txt`. Also save subset versions of `propYearDf.csv` for sims which meet these critera (`./data_simulations/propYearDfCriteriaTrue.csv`) or don't (`./data_simulations/propYearDfCriteriaFalse.csv`).

- `./4_plot_boxplots.sh`: Plots boxplots for timing that polygons reach a given threshold inf prop, or the same but for the subset of sims that meet (or don't meet) the selection criteria: `./plots/criteria_*`
