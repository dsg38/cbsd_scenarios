options(stringsAsFactors = F)
library(tictoc)

minimalDfs = function(targetDfPath){

    tic()
    bigDf = readRDS(targetDfPath)
    toc()

    # -------------------------------------------

    keepColsTarget = c(
        "simKey", 
        "Kernel_0_Parameter", 
        "Kernel_0_WithinCellProportion", 
        "Rate_0_Sporulation"
    )

    minimalTargetDf = unique(bigDf[,keepColsTarget])

    outPathTarget = file.path(dirname(targetDfPath), "results_summary_fixed_TARGET_MINIMAL.rds")
    saveRDS(minimalTargetDf, outPathTarget)

    # ---------------

    keepColsShrink = c(
        "simKey",
        "polyName",
        "targetDiff",
        "polySuffix",
        "surveyDataYear",
        "targetVal",
        "infProp"
    )

    outDfShrink = bigDf[,keepColsShrink]
    
    outPathShrink = file.path(dirname(targetDfPath), "results_summary_fixed_TARGET_SHRINK.rds")
    saveRDS(outDfShrink, outPathShrink)

}
