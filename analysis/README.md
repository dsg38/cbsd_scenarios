# Overview of analysis code

NB: All paths are relative to this README dir

## Pre-processing

### Isolate which sims meet individual simulated survey stats constraints

**Script: `results/*/*/preprocess_sim_survey.R`**

Work out which sims have sim survey stats that meet a defined condition. For example, fall within a given tolerance of target data

Dependencies:

- `package_sim_survey/utils_analysis_sim_survey.R` = Funcs that extract sims that match a given sim survey condition

Inputs:

- `results/*/*/output/management_results.rds`
- Specify sets of 1) poly names, 2) specific constraint (i.e. corresponding function from `utils_analysis_sim_survey.R`) and 3) tolerance if appropriate

Output:

- `results/*/*/output/results_sim_survey.json`

### Isolate which sims meet individual inf raster constraints

**Script: `results/*/*/preprocess_inf_rasters.R`**

Work out which sims in a given polygon at a given time (normally instantaneous start of a year e.g. 2018, equivalent of end of 2017) contain any fields with CBSD infection.

Inputs: 

- `output/raster_poly_stats_agg_minimal.rds`

Outputs:

- `output/results_inf_polys.json`

## Analysis

### Isolate sims which meet multiple constraints

**Script: `results/*/*/analyse.R`**

This script


Dependencies:

- `./utils_analysis.R`

Inputs

- `results/*/*/output/results_sim_survey.json`
- `output/results_inf_polys.json`



<!-- # Process

Run `process_sim_output.R`

If necessary, run `process_merge.R`

# Analysis -->



