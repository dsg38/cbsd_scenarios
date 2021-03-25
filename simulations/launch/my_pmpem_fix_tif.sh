#!/bin/bash

module load R-with-libraries

echo "LAUNCHING TIF PROCESSING:"
echo "$@"

Rscript /rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/cbsd_scenarios/simulations/launch/my_pmpem_fix_tif.R "$@"
