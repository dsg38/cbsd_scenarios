box::use(../../utils/utils_surveillance)
box::use(tictoc[...])

optimalDfPath = "./data/optimalDf.csv"
sweepDirTop = "./sweep/"

outDir = "./data/simple_clusters/"

# --------------------------

dir.create(outDir, showWarnings = FALSE, recursive = TRUE)

optimalDf = read.csv(optimalDfPath)




# sweepDir = file.path(sweepDirTop, paste0("sweep_", "80"), "outputs")

# outPath = file.path(outDir, paste0("sweep_", "80", ".gpkg"))

# utils_surveillance$genSimpleClustersSf(
#     sweepDir = sweepDir,
#     outPath = outPath
# )



tic()
for(iRow in seq_len(nrow(optimalDf))){
    
    print(iRow)
    
    thisRow = optimalDf[iRow,]
    
    sweepDir = file.path(sweepDirTop, paste0("sweep_", thisRow$sweep_i), "outputs")
    
    outPath = file.path(outDir, paste0("sweep_", thisRow$sweep_i, ".gpkg"))
    
    utils_surveillance$genSimpleClustersSf(
        sweepDir = sweepDir,
        outPath = outPath
    )
    
}
toc()
