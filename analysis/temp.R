x = readRDS("results/2021_03_17_cross_continental/2021_03_18_batch_0/results_summary_fixed_TARGET.rds")

y = readRDS("/home/dsg38/Documents/gilligan_lab/cbsd_landscape_model/analysis/results_validation/sim_output_agg/model_2/2020_12_20_prelim_validation/survey_data_C/survey_data_C/results_summary_fixed_TARGET.rds")


z = y[is.na(y$targetDiff),]


unique(z$polyName)
