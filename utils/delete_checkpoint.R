topDir = "../simulations/sim_output/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/"

endStateFileName = "O_0_L_0_INFECTIOUS_2054.000000.tif"

txtRasterPaths = normalizePath(list.files(topDir, pattern=endStateFileName, full.names = T, recursive = T))


# Take each dir and see if a dtcp checkpoint is there - if so, delete


