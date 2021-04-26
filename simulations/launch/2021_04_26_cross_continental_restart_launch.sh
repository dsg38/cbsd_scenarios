#!/bin/bash

module load python3
module load pmpem

python3.sh my_pmpem.py \
-o "../sim_output/2021_03_26_cross_continental/2021_04_26_batch_0/" \
--nsamplesperparamset 1 \
--densityfile "../../inputs/inputs_raw/params/2009_1_tol_0_65_mask_10_posterior.txt" \
--opertype pd \
--scheduler s \
--slurmqueue "SL2" \
--memoryrequest 17940 \
--runtimerequest "36:00:00" \
--parametersfile "2021_04_26_cross_continental_restart_params.txt" \
--landscapefolder "/rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/cbsd_scenarios/inputs/inputs_scenarios/2021_03_17_cross_continental/inputs" \
--launchscript `readlink -f $0` \
--dmtcp_restart_limit 10
