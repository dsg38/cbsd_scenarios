# Overview of analysis code

NB: All paths are relative to this README dir

## Pre-processing

### Check all sims have finished

Script `../../utils_hpc/check_sim_status.py`

Single arg path to batch e.g: `python check_sim_status.py "../cbsd_scenarios/simulations/sim_output/2022_03_15_cross_continental_endemic/2022_03_20_batch_0/"`

Outputs:

- Saves `progress.csv` inside batch folder

### Surveillance data-based stats

#### Aggregate sim survey simulation output

Script: `package_sim_survey/process_sim_output.R`

Inputs:

- Launch script for simulations e.g. `../../simulations/launch/2021_03_17_cross_continental_launch.sh`
- `progress.csv` inside batch dir

Outputs:

- `./results/2022_03_15_cross_continental_endemic/2022_03_20_batch_0/output/management_stacked.rds`
- `./results/2022_03_15_cross_continental_endemic/2022_03_20_batch_0/output/management_results.rds`

e.g. `Rscript process_sim_output.R ../../simulations/launch/2022_03_15_cross_continental_endemic_launch.sh`

#### Isolate which sims meet individual simulated survey stats constraints

**Script: `results/*/*/preprocess_sim_survey.R`**

Work out which sims have sim survey stats that meet a defined condition. For example, fall within a given tolerance of target data

Dependencies:

- `package_sim_survey/utils_analysis_sim_survey.R` = Funcs that extract sims that match a given sim survey condition

Inputs:

- `results/*/*/output/management_results.rds`
- Specify sets of 1) poly names, 2) specific constraint (i.e. corresponding function from `utils_analysis_sim_survey.R`) and 3) tolerance if appropriate

Output:

- `results/*/*/output/results_sim_survey.json`

### Infectious raster-based stats

#### Extract stats within given polygons

**Script: `package_inf_rasters/gen_poly_stats.R`**

Generates a df with a summary, for each given raster (e.g. t=0, t=1), how much infection is present in each of the given polygons (e.g. Uganda). The 'amount of infection' is reported in terms of number of cells, number of fields, and proportion of fields (relative to total host in poly).

Inputs:

- A given simulation job folder e.g. job0
- A polygon sf gpkg with the polgons to extract the stats within
- Host raster (to allow inf raster to be converted to num inf fields raster)

Outputs:

- e.g. `../simulations/sim_output/2022_03_02_endemic_seed/2022_03_02_batch_0/job0/output/runfolder0/raster_poly_stats.rds`

NB: `launch_slurm_gen_poly_stats.sh` allows this to be launched as a slurm job for all sim output jobs.


#### Aggregate all the inf poly stats for a given batch

**Script: `package_inf_rasters/aggregate.R`**

Loops over all the job dirs for a given batch and glues together all the job level `raster_poly_stats.rds` files

Inputs:

- e.g. `../simulations/sim_output/2022_03_02_endemic_seed/2022_03_02_batch_0/job*/output/runfolder0/raster_poly_stats.rds`

Outputs:

- e.g. `../simulations/sim_output/2022_03_02_endemic_seed/2022_03_02_batch_0/raster_poly_stats_agg.rds`
- e.g. `../simulations/sim_output/2022_03_02_endemic_seed/2022_03_02_batch_0/raster_poly_stats_agg_minimal.rds`

TODO: Should these actually be written out to this analysis dir rather than the simulations dir? What makes sense?

#### Isolate which sims meet individual inf raster constraints

**Script: `results/*/*/preprocess_inf_rasters.R`**

Work out which sims in a given polygon at a given time (normally instantaneous start of a year e.g. 2018, equivalent of end of 2017) contain any fields with CBSD infection.

Inputs: 

- `output/raster_poly_stats_agg_minimal.rds`

Outputs:

- `output/results_inf_polys.json`

## Analysis

### Isolate sims which meet multiple constraints

**Script: `results/*/*/analyse.R`**

This script combines any set of constraints to isolate the simulations that meet these constraints. The script then plots a histogram of the years in which these simulations lead to infection in the infectious raster within a given polygon (e.g. arrival times of CBSD in Nigeria).

Dependencies:

- `./utils_analysis.R`

Inputs:

- `results/*/*/output/results_sim_survey.json`
- `output/results_inf_polys.json`

Outputs:

- `plots/*.png`


<!-- # Process

Run `process_sim_output.R`

If necessary, run `process_merge.R`

# Analysis -->



