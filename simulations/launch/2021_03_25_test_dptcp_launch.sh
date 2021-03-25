#!/bin/bash

module load python3
module load pmpem

python3.sh my_pmpem.py \
-o "../sim_output/2021_03_25_test_dptcp/2021_03_25_batch_0/" \
--nsamplesperparamset 10 \
--densityfile "../../inputs/inputs_raw/params/2009_1_tol_0_65_mask_10_posterior.txt" \
--opertype pd \
--scheduler s \
--slurmqueue "SL2" \
--memoryrequest 5980 \
--parametersfile "2021_03_25_test_dmtcp_params.txt" \
--runtimerequest "00:20:00" \
--landscapefolder "/rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/cbsd_scenarios/inputs/inputs_scenarios/2021_03_17_uganda/inputs" \
--launchscript `readlink -f $0` \
--dmtcp_restart_limit 10
