#!/bin/bash
python3.sh ../my_pmpem.py \
-o "../../sim_output/2021_03_17_uganda/2021_03_17_batch_0/" \
--nsamplesperparamset 10 \
--densityfile "../../../inputs/inputs_raw/params/2009_1_tol_0_65_mask_10_posterior.txt" \
--opertype pd \
--scheduler l \
--slurmqueue "SL3" \
--memoryrequest 5980 \
--parametersfile "params.txt" \
--runtimerequest "12:00:00" \
--landscapefolder "/rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/cbsd_scenarios/inputs/inputs_scenarios/2021_03_17_uganda/inputs"

