# Setting up new scenarios

Depending on the scenario, will want to generate different kinds of outputs and carry out different kinds of analysis. The main kinds are:

* Simulate surveillance by explicitly stating survey locations and timing (generally based on real-world survey data locations).
* Analyse infection arrival times at different locations.
* Analyse infection statistics in relation to host landscape e.g. proportion of fields infected in a given poly

The only difference in the sim survey vs. inf raster analysis is looking at infection either directly (inf rasters), or through the lens of a surveillance scheme.

**All of these involve the generation of polygons, within which stats are calculated. Either stats on sim survey output or stats on the underlying inf rasters.**

## Generating polygons 

**Script: `inputs/process_polys`**

The `utils.R` box module in this dir contains functions that can be used to build `polys_n.gpkg` files.

For each new polys file, there's a new script at the top level that generates the outputs.

There are two different output types:
* For inf raster statistics, the polygon sf df with host landscape statistics appended. Given that these have data specific to a host landscape, they are named as such e.g. `inputs/inputs_raw/polygons/polys_0_host_default.gpkg` 
* Generation of sim survey target data within each polygon in the polys sf df. These files are saved underneath the sim survey rasters. See below sim survey section form ore details

## Simulated surveillance

### Generating XY indexes

**Script: `inputs/build_inputs.R`**

The goal is to specify the locations where I want simulated surveillance to occur. 

If the `config.json` contains `processSurvey` key and info specifying:

* Survey rasters
* Polygon sf df

Then the script will

* Crop the survey rasters to scenario extent
* For each polygon in each survey raster (i.e. year), generate a csv that specifies the zero indexed XY raster cell indexes for the survey points that fall within that polygon. 
  * The simulator outputs an equivalent XY index table for a given time point (survey raster), so this allows the corresponding sim survey output for a given mask/time to be easily extracted i.e. based on matching XY
  * This XY index output is saved in the scenario dir in a folder called `survey_poly_index`. It has to be calculated on a scenario basis as the zero indexed XY raster cell positions depend on the extent of the scenario. So cannot be stored with the raw polygons / sim survey rasters.


### Calculate the proportion of survey points that are infected within a given polygon at a given time (i.e. infectious proportion stats)

**Script: e.g. `inputs/process_polys/polys_0.R`**

**NB: This is a work in progress (limited as code migrated from context where only one set of survey data). Maybe merge into `build_inputs.R` script?**

Inputs:

* The poly sf df
* The survey data **as a csv rather than based on the survey rasters themselves (bit hacky)**

Outputs:

* With the `inputs_raw/survey_rasters` data, for a given poly sf df (e.g. `polys_0`), saves csvs specifying the per poly yearly inf prop.


### Aggregate simulated survey stats and append target data for easy comparison (i.e. compare simulated inf prop to real world inf prop)

**Script: `analysis/package_sim_survey/process_sim_output.R`**

**NB: This is also a work in progress and probably too specific in terms of previous use cases from ABC stuff**

By pointing at the batch launch script, this script finds the inputs:

`extractPolygonStats`:

* This func uses the XY index data above to generate stats on the simulations for each mask

`appendSurveyDataTargetData`

* This func looks at the target data for each mask / time point and appends to the sim output stats. So the simulated poly stats can be easily compared to target data stats.


### Analyse simulated surveillance results

**Script: `analysis/package_sim_survey/utils_analysis_sim_survey.R`**

This `utils_analysis_sim_survey.R` box module provides the functions to analyse different scenarios.

The scripts that use these utils to analyse results live in the relevant `analysis/results/` folder i.e. with the specific scenario data.

## Infection rasters (arrival times in different polys)

### Generating polys

See top level section for details.

### Processing inf rasters to generate stats for each inf raster / year per poly




### Analysing stats














<!-- Currently, this script is heavily based on the goals of the fitting i.e. find which simulations have simulated surveys that, based on inf prop stats, match the target survey data.

It has a hacked in feature to check for infection in different parts of DRC.

But will likely be extensively modified / generalised soon. -->


<!-- 
## Polys for arrival time / host inf prop stats

### Steps whilst generating scenario input

In addition to the above poly creation functionality, the `process_polys` package also:

* For a given batch of sim survey rasters, generate time course inf prop stats for each poly in the sf df
  * TODO: This is currently based on the XY survey data rather than generating from the rasters. Might be worth refactoring in some way e.g. include in pipeline generating XY data, then rasters etc.

The key output to feed into the analysis stage is the inf prop  

### Steps post-simulation (`analysis` dir)
 -->

