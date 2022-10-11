box::use(../../utils/utils_surveillance)

configSweepPath = "./config_sweep.json"

optimalDf = utils_surveillance$genSweepOptimalDf(configSweepPath)

dataDir = file.path(dirname(configSweepPath), "data")
dir.create(dataDir, showWarnings = FALSE, recursive = TRUE)

optimalDfPath = file.path(dataDir, "optimalDf.csv")

write.csv(optimalDf, optimalDfPath, row.names = FALSE)

# Gen plot dir
plotDir = file.path(dirname(configSweepPath), "plots")

utils_surveillance$genSweepSurfacePlot(
    optimalDf = optimalDf,
    plotDir = plotDir
)
