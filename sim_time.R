progressDf = read.csv("./simulations/sim_output/2022_03_15_cross_continental_endemic/2022_03_20_batch_0/progress.csv")

timeHours = progressDf$simWallClockDurationSeconds / 60 / 60

hist(timeHours)
max(timeHours)
