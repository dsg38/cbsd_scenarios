args = commandArgs(trailingOnly=TRUE)

topDir = args[[1]]
mergedStr = args[[2]]

# topDir = "results/2021_03_26_cross_continental/"
# mergedStr = "2021_04_22_merged"

# ------------------------

outDir = file.path(topDir, mergedStr)
dir.create(outDir, recursive = T, showWarnings = F)

batchPaths = list.files(topDir, pattern="_batch_", full.names = T)

# -----------------------

dfNameVec = c(
  "results_summary_fixed_TARGET.rds"
)

for(thisDfName in dfNameVec){
  
  print(thisDfName)

  outPath = file.path(outDir, thisDfName)
  
  dfList = list()
  for(thisBatchPath in batchPaths){
    
    print(thisBatchPath)
      
    thisDfPath = file.path(thisBatchPath, thisDfName)
    dfList[[thisDfPath]] = readRDS(thisDfPath)
        
  }
  
  outDf = dplyr::bind_rows(dfList)
  
  saveRDS(outDf, outPath)
  
}

# Write out batchlist
logOutPath = file.path(outDir, "batchlist.txt")
fileConn=file(logOutPath)
writeLines(batchPaths, fileConn)
close(fileConn)

