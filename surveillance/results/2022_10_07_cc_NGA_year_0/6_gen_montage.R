box::use(../../utils/utils_surveillance)

configSweepPath = "./config_sweep.json"
optimalDfPath = "./data/optimalDf.csv"
# individualPlotsDir = "./plots/simple_grid"
# individualPlotsDir = "./plots/simple_clusters"
individualPlotsDir = "./plots/points"

outPlotPath = file.path("./plots/simple_montage", paste0("montage_", basename(individualPlotsDir), ".png"))

# ----------------------------

utils_surveillance$genMontage(
    configSweepPath = configSweepPath,
    optimalDfPath = optimalDfPath,
    individualPlotsDir = individualPlotsDir,
    outPlotPath = outPlotPath
)
