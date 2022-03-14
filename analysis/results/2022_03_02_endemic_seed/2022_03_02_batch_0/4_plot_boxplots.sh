#!/bin/bash

Rscript "../../../package_boxplot/boxplot_plot.R" "./data_simulations/propYearDf.csv" "./plots/criteria_none"

Rscript "../../../package_boxplot/boxplot_plot.R" "./data_simulations/propYearDfCriteriaTrue.csv" "./plots/criteria_true"

Rscript "../../../package_boxplot/boxplot_plot.R" "./data_simulations/propYearDfCriteriaFalse.csv" "./plots/criteria_false"
