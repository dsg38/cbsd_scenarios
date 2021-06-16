#!/bin/bash

module load python3
module load pmpem

python3.sh YEV_my_pmpem.py \
-o "../sim_output/yev/yev_0/" \
--nsamplesperparamset 1 \
--densityfile "YEV_posterior.txt" \
--opertype pd \
--scheduler s \
--slurmqueue "SL2" \
--memoryrequest 17940 \
--parametersfile "YEV_params.txt" \
--runtimerequest "01:00:00" \
--landscapefolder "/rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/cbsd_scenarios/inputs/inputs_scenarios/2021_03_17_cross_continental/inputs" \
--launchscript `readlink -f $0` \
--dmtcp_restart_limit 10
