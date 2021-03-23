options(stringsAsFactors = F)
library(dplyr)
library(ggplot2)
library(ggfan)
library(tictoc)
source("utils/FUNC_fitting.R")
source("utils/FUNC_plot_posterior.R")
args = commandArgs(trailingOnly=TRUE)

# topDataDir = args[[1]]
# configDir = args[[2]]

# paramsPath = NULL
# if(length(args) == 3){
#   paramsPath = args[[3]]
# }

topDataDir = "results/2021_03_17_cross_continental/2021_03_18_batch_0"
configDir = "results/2021_03_17_cross_continental/config"

# -----

configMasksDfAllPath = file.path(configDir, "config_mask.csv")
configGridDfPath = file.path(configDir, "config_grid.csv")

configKey = basename(configDir)

# -----------------------
unqKey = paste0(format(Sys.time(), "%Y_%m_%d_%H%M%S"), "_", configKey)
topOutDir = file.path(gsub("sim_output_agg", "fitting_output", topDataDir), unqKey)

print("OUTPATH:")
print(topOutDir)

bigDfPath = file.path(topDataDir, "results_summary_fixed_TARGET_SHRINK.rds")
bigMinimalDfPath = file.path(topDataDir, "results_summary_fixed_TARGET_MINIMAL.rds")
gridDfPath = file.path(topDataDir, "grid_yearly_pass_prop.rds")

# --------------------------

configMaskDfAll = read.csv(configMasksDfAllPath)
configMaskDfList = split(configMaskDfAll, configMaskDfAll$fit)

configGridDf = read.csv(configGridDfPath)

# Read big file
tic()
bigDfRaw = readRDS(bigDfPath)
toc()
# --------------------

# TODO: Make dropping 2016 more formal?
bigDfDropped = bigDfRaw[!bigDfRaw$surveyDataYear==2016,]
bigDf = bigDfDropped[!is.na(bigDfDropped$targetDiff),]

bigMinimalDf = readRDS(bigMinimalDfPath)
gridDf = readRDS(gridDfPath)

# ------------------------------

# Calc all grid first
gridPassList = passGridFun(gridDf, configGridDf)


# Inf prop etc.
numJobs = length(names(configMaskDfList)) * length(names(gridPassList))

count = 0
for(maskKey in names(configMaskDfList)){
  
  configMaskDf = configMaskDfList[[maskKey]]
  
  yearResultsList = calcInfPropFun(bigDf, configMaskDf)
    
  outDir = file.path(topOutDir, maskKey)
  dir.create(outDir, showWarnings = F, recursive = T)
  
  print(paste0("prog: ", round(count/numJobs, 3) * 100, "%"))
  
  # ------------
  
  thisFitResultsList = calcYearlyStats(
    configMaskDf=configMaskDf, 
    yearResultsList=yearResultsList, 
    maskKey=maskKey, 
    gridKey="", 
    gridPassList=gridPassList
  )
  
  yearSummaryDf = thisFitResultsList[["yearSummaryDf"]]
  passKeysAll = thisFitResultsList[["passKeysAll"]]
  
  # Write out summary
  yearSummaryDfOutPath = file.path(outDir, "year_summary_df.csv")
  write.csv(yearSummaryDf, yearSummaryDfOutPath, row.names = F)
  
  if(length(passKeysAll) > 0){
    
    # Plot pass rate
    passRatePlotOutPath = file.path(outDir, "pass_rate.png")
    plotPassRate(yearSummaryDf, passRatePlotOutPath)
    
    # Write out passKeys
    passKeysAllDf = data.frame(passKeys=passKeysAll)
    passKeysAllDfOutPath = file.path(outDir, "passKeys.csv")
    write.csv(passKeysAllDf, passKeysAllDfOutPath, row.names = F)
    
    # Plot posterior
    plotPosterior(
      bigMinimalDfRaw=bigMinimalDf,
      passKeysDf=passKeysAllDf,
      plotDir=outDir,
      plotTitle=maskKey,
      paramsPath=paramsPath
    )

    # Plot infProp graphs
    plotInfPropAllPoly(bigDf, configMaskDf, passKeysAll, maskKey, outDir)
    
  }
  
  count = count + 1
  
  # }

}

# Aggregate
aggCmd = paste0("python utils/fit_1_agg_results.py ", topOutDir)
system(aggCmd)
