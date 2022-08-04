
riskYearVec = c(2023, 2030, 2040, 2050)

outDir = "./output/diff/rasters/"
outDirDiag = "./output/diff/rasters/diagnostics/"

dir.create(outDir, recursive = TRUE, showWarnings = FALSE)
dir.create(outDirDiag, recursive = TRUE, showWarnings = FALSE)

genDiagnostics = function(diffRaster, outPath){

    diffRasterVals = diffRaster[]

    propNa = round((sum(is.na(diffRasterVals)) / length(diffRasterVals)),2)
    propZero = round((sum(diffRasterVals==0, na.rm = TRUE) / length(diffRasterVals)), 2)

    png(outPath)
    hist(diffRasterVals, main=paste0(basename(outPath), "|na:", propNa, "|0:", propZero))
    dev.off()

}

for(i in seq_len(length(riskYearVec) - 1)){

    print(i)

    rasterYearPrev = riskYearVec[i]
    rasterYearNow = riskYearVec[i+1]

    # ------------------------------

    riskRasterPathPrev = file.path("./output/risk/", paste0("risk_", rasterYearPrev,".tif"))
    riskRasterPathNow = file.path("./output/risk/", paste0("risk_", rasterYearNow,".tif"))

    # --------------------------------

    processRaster = function(riskRasterPath){

        riskRaster = raster::raster(riskRasterPath)

        # Set NAs to zeros so no possible issues with calc
        riskRaster[is.na(riskRaster)] = 0

        return(riskRaster)
    }

    riskRasterPrev = processRaster(riskRasterPathPrev)
    riskRasterNow = processRaster(riskRasterPathNow)

    # Calculate diff
    diffRaster = riskRasterNow - riskRasterPrev

    # Set any zeros to NA
    diffRaster[diffRaster == 0] = NA

    # Diff raster prop
    # diffRasterProp = diffRaster / riskRasterNow
    diffRasterProp = diffRaster / (riskRasterPrev + 0.001)

    # --------------------------------

    outPath = file.path(outDir, paste0("diff_", rasterYearPrev, "_", rasterYearNow, ".tif"))
    outPathProp = file.path(outDir, paste0("diffprop_", rasterYearPrev, "_", rasterYearNow, ".tif"))

    raster::writeRaster(diffRaster, outPath, overwrite=TRUE)
    raster::writeRaster(diffRasterProp, outPathProp, overwrite=TRUE)

    # --------------------------------
    # Diagnostics
    outPathDiag = file.path(outDirDiag, paste0("diff_", rasterYearPrev, "_", rasterYearNow, ".png"))
    outPathDiagProp = file.path(outDirDiag, paste0("diffprop_", rasterYearPrev, "_", rasterYearNow, ".png"))

    genDiagnostics(diffRaster, outPathDiag)
    genDiagnostics(diffRasterProp, outPathDiagProp)


}
