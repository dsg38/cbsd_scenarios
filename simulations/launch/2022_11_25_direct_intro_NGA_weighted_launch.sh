#!/bin/bash

module load python3
module load pmpem

python3.sh my_pmpem.py \
-o "../sim_output/2022_11_25_direct_intro_NGA_weighted/2022_11_25_batch_0/" \
--nsamplesperparamset 1000 \
--densityfile "../../inputs/inputs_raw/params/2022_02_04_model_2_posterior.txt" \
--opertype pd \
--scheduler s \
--slurmqueue "SL2" \
--memoryrequest 3420 \
--parametersfile "2022_11_25_direct_intro_NGA_weighted_params.txt" \
--runtimerequest "12:00:00" \
--landscapefolder "/rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/cbsd_scenarios/inputs/inputs_scenarios/2022_11_25_direct_intro_NGA_weighted/inputs" \
--launchscript `readlink -f $0` \
--dmtcp_restart_limit 30 \
--dmtcp_checkpoint_secs 39600
