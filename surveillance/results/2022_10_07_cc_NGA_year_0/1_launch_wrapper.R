box::use(../../utils/sa)
args = commandArgs(trailingOnly=TRUE)

configPath = args[[1]]

sa$sa_wrapper(configPath)
