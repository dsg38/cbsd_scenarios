box::use(../../utils/utils_surveillance)

optimalDfPath = "./data/optimalDf.csv"
polyDfPath = "../../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg"
countryCode = "NGA"
sweepDirTop = "./sweep/"

outDir = "./data/simple_grid/"

dir.create(outDir, showWarnings = FALSE, recursive = TRUE)

optimalDf = read.csv(optimalDfPath)

for(iRow in seq_len(nrow(optimalDf))){
    
    print(iRow)
    
    thisRow = optimalDf[iRow,]
    
    sweepDir = file.path(sweepDirTop, paste0("sweep_", thisRow$sweep_i), "outputs")
    
    outPath = file.path(outDir, paste0("simple_grid_sweep_", thisRow$sweep_i, ".gpkg"))
    
    utils_surveillance$genSimpleGridSf(
        sweepDir = sweepDir,
        polyDfPath = polyDfPath,
        countryCode = countryCode,
        outPath = outPath
    )
    
}







