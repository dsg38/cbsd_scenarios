box::use(../../utils/sa_clusters)
# box::reload(sa_clusters)
args = commandArgs(trailingOnly=TRUE)

# configPath = args[[1]]

configPath = "./outputs/config.json"

sa_clusters$sa_wrapper(configPath)
