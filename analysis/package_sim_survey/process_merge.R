args = commandArgs(trailingOnly=TRUE)

topDir = args[[1]]
mergedDir = args[[2]]

# topDir = "results/2021_03_26_cross_continental/"
# mergedDir = "2021_04_29_merged"

# ------------------------

outDir = file.path(topDir, mergedDir)
dir.create(outDir, recursive = T, showWarnings = F)

batchPaths = list.files(topDir, pattern="_batch_", full.names = T)

# -----------------------

dfNameVec = c(
  "management_results.rds"
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

