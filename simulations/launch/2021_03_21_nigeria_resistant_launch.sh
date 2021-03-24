#!/bin/bash

module load python3
module load pmpem

python3.sh my_pmpem.py \
-o "../sim_output/2021_03_21_nigeria_resistant/2021_03_21_batch_1/" \
--nsamplesperparamset 10 \
--densityfile "../../inputs/inputs_raw/params/2009_1_tol_0_65_mask_10_posterior.txt" \
--opertype pd \
--scheduler s \
--slurmqueue "SL2" \
--memoryrequest 5980 \
--runtimerequest "16:00:00" \
--parametersfile "2021_03_21_nigeria_resistant_params.txt" \
--landscapefolder "/rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/cbsd_scenarios/inputs/inputs_scenarios/2021_03_18_nigeria_region/inputs" \
--launchscript "/rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/cbsd_scenarios/simulations/launch/2021_03_21_nigeria_resistant_launch.sh" \
--dmtcp_restart_limit 10 
