#!/bin/bash

module load python3
module load pmpem

python3.sh my_pmpem.py \
-o "../sim_output/2022_03_15_cross_continental_endemic/2022_03_15_batch_0/" \
--nsamplesperparamset 1000 \
--densityfile "../../inputs/inputs_raw/params/2022_02_04_model_2_posterior.txt" \
--opertype pd \
--scheduler s \
--slurmqueue "SL3" \
--memoryrequest 13680 \
--runtimerequest "12:00:00" \
--parametersfile "2022_03_15_cross_continental_endemic_params.txt" \
--landscapefolder "/rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/cbsd_scenarios/inputs/inputs_scenarios/2022_03_15_cross_continental_endemic/inputs" \
--launchscript `readlink -f $0` \
--dmtcp_restart_limit 50 \
--dmtcp_checkpoint_secs 39600
