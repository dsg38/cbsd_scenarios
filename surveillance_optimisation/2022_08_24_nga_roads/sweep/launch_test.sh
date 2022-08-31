# SLURM_ARRAY_TASK_ID=0

# echo "./results/sweep_$SLURM_ARRAY_TASK_ID/config.json"

Rscript "../temp_sa_no_comp.R" "./results/sweep_0/config.json" "../data/brick.tif" "../data/sumRasterMaskPointsDf.csv"
