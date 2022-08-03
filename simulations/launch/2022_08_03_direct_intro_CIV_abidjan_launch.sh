#!/bin/bash

module load python3
module load pmpem

python3.sh my_pmpem.py \
-o "../sim_output/2022_08_03_direct_intro_CIV_abidjan/2022_08_03_batch_0/" \
--nsamplesperparamset 1000 \
--densityfile "../../inputs/inputs_raw/params/2022_02_04_model_2_posterior.txt" \
--opertype pd \
--scheduler s \
--slurmqueue "SL2" \
--memoryrequest 6840 \
--parametersfile "2022_08_03_direct_intro_params.txt" \
--runtimerequest "36:00:00" \
--landscapefolder "/rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/cbsd_scenarios/inputs/inputs_scenarios/2022_08_03_direct_intro_CIV_abidjan/inputs" \
--launchscript `readlink -f $0` \
--dmtcp_restart_limit 30 \
--dmtcp_checkpoint_secs 122400
