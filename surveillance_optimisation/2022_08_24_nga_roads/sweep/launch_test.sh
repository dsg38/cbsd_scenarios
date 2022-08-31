#!/bin/bash

# SLURM_ARRAY_TASK_ID=0

# echo "./results/sweep_$SLURM_ARRAY_TASK_ID/config.json"

# Rscript "../temp_sa_no_comp.R" "./results/sweep_6/config.json" "../data/brick.tif" "../data/sumRasterMaskPointsDf.csv"

for i in {1..15}
do
    echo $i

    Rscript "../temp_sa_no_comp.R" "./results/sweep_$i/config.json" "../data/brick.tif" "../data/sumRasterMaskPointsDf.csv"

done
