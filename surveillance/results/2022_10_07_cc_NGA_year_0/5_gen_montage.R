box::use(../../utils/utils_surveillance)

configSweepPath = "./config_sweep.json"
optimalDfPath = "./data/optimalDf.csv"
plotDir = "./plots/"

# ----------------------------

utils_surveillance$genMontage(
    configSweepPath = configSweepPath,
    optimalDfPath = optimalDfPath,
    plotDir = plotDir
)
