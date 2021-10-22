#!/bin/bash

module load python3
module load pmpem

python3.sh my_pmpem.py \
-o "../sim_output/2021_10_21_cross_continental_endemic/2021_10_21_batch_0/" \
--nsamplesperparamset 1000 \
--densityfile "../../inputs/inputs_raw/params/2009_1_tol_0_65_mask_10_posterior.txt" \
--opertype pd \
--scheduler s \
--slurmqueue "SL3" \
--memoryrequest 13680 \
--runtimerequest "12:00:00" \
--parametersfile "2021_10_21_cross_continental_endemic_params.txt" \
--landscapefolder "/rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/cbsd_scenarios/inputs/inputs_scenarios/2021_10_21_cross_continental_endemic/inputs" \
--launchscript `readlink -f $0` \
--dmtcp_restart_limit 30 \
--dmtcp_checkpoint_secs 39600
