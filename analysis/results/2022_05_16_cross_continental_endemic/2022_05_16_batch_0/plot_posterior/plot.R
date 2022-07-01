library(ggplot2)
library(dplyr)
library(raster)
library(ggspatial)
library(rasterVis)

plotPosterior = function(
    bigDfPath,
    passKeysDfPath,
    plotDir,
    plotPrefix,
    plotPath,
    passKeysDfPredroppedPath=NULL,
    paramsRow=NULL
){

    keyKernalAlphaVal = NULL
    keyLogBetaVal = NULL
    keyKernelPVal = NULL
    if(!is.null(paramsRow)){
                
        keyKernalAlphaVal = paramsRow$Kernel_0_Parameter
        keyLogBetaVal = paramsRow$Rate_0_Sporulation_log
        keyKernelPVal = paramsRow$Kernel_0_WithinCellProportion

    }

    configList = list()

    configList[["a"]] = list()
    configList[["a"]][["xKey"]] = "Kernel_0_Parameter"
    configList[["a"]][["yKey"]] = "Rate_0_Sporulation_log"
    # configList[["a"]][["plotName"]] = "posterior_alpha_beta.png"
    configList[["a"]][["xlab"]] = expression(italic(α))
    configList[["a"]][["ylab"]] = expression(ln(italic(β)))
    configList[["a"]][["xintercept"]] = keyKernalAlphaVal
    configList[["a"]][["yintercept"]] = keyLogBetaVal

    # configList[["b"]] = list()
    # configList[["b"]][["xKey"]] = "Kernel_0_Parameter"
    # configList[["b"]][["yKey"]] = "Kernel_0_WithinCellProportion"
    # configList[["b"]][["plotName"]] = "posterior_alpha_p.png"
    # configList[["b"]][["xlab"]] = expression(italic(α))
    # configList[["b"]][["ylab"]] = expression(italic(p))
    # configList[["b"]][["xintercept"]] = keyKernalAlphaVal
    # configList[["b"]][["yintercept"]] = keyKernelPVal

    # configList[["c"]] = list()
    # configList[["c"]][["xKey"]] = "Rate_0_Sporulation_log"
    # configList[["c"]][["yKey"]] = "Kernel_0_WithinCellProportion"
    # configList[["c"]][["plotName"]] = "posterior_beta_p.png"
    # configList[["c"]][["xlab"]] = expression(ln(italic(β)))
    # configList[["c"]][["ylab"]] = expression(italic(p))
    # configList[["c"]][["xintercept"]] = keyLogBetaVal
    # configList[["c"]][["yintercept"]] = keyKernelPVal

    for(thisConfigName in names(configList)){

        xKey = configList[[thisConfigName]][["xKey"]]
        yKey = configList[[thisConfigName]][["yKey"]]
        # plotName = configList[[thisConfigName]][["plotName"]]
        xlab = configList[[thisConfigName]][["xlab"]]
        ylab = configList[[thisConfigName]][["ylab"]]
        xintercept = configList[[thisConfigName]][["xintercept"]]
        yintercept = configList[[thisConfigName]][["yintercept"]]

        # plotPath = file.path(plotDir, paste0(plotPrefix, plotName))

        dir.create(plotDir, recursive = TRUE, showWarnings = FALSE)

        print(plotPath)

        bigDf = readRDS(bigDfPath) |>
            dplyr::mutate(
                Rate_0_Sporulation_log = log(Rate_0_Sporulation), 
                batch=substr(simKey, 1, 18)
            )

        passKeysDf = read.csv(passKeysDfPath)

        # ----------------------------

        bigDfPass = bigDf[bigDf$simKey%in%passKeysDf$passKeys,]

        sampleDf = data.frame(
            x=bigDf[[xKey]],
            y=bigDf[[yKey]]
        )

        passDf = data.frame(
            x=bigDfPass[[xKey]],
            y=bigDfPass[[yKey]]
        )

        # Build convex hull of all sims
        hull = bigDf[chull(bigDf[[xKey]], bigDf[[yKey]]),]

        # ---------------------------
        # Rasterise pass and sample data
        xmn=round(min(bigDf[[xKey]]), digits = 1)
        xmx=round(max(bigDf[[xKey]]), digits = 1)
        ymn=round(min(bigDf[[yKey]]), digits = 1)
        ymx=round(max(bigDf[[yKey]]), digits = 1)

        templateRaster = raster(
            xmn=xmn,
            xmx=xmx,
            ymn=ymn,
            ymx=ymx,
            resolution=c(0.07)
        )

        sampleRaster = rasterize(sampleDf, templateRaster, fun="count")
        passRaster = rasterize(passDf, templateRaster, fun="count")

        # Calc normalised pass raster
        passRateRaster = passRaster / sampleRaster

        # Plot
        p = gplot(passRateRaster) +
            geom_tile(aes(fill = value)) +
            scale_fill_continuous(na.value="transparent") +
            # geom_polygon(data = hull, aes_string(x=xKey, y=yKey), alpha = 0.2) +
            labs(fill="Density") + 
            guides(fill = guide_colourbar(ticks.linewidth = 3)) + 
            ylim(5, 6.75) +
            xlim(2.5, 4.6) +
            xlab(xlab) +
            ylab(ylab) +
            theme(text = element_text(size=25)) +
            theme(legend.position="none", plot.background = element_rect(colour = "black", fill="white", size=3.5)) +
            geom_vline(xintercept=xintercept, color = "green", size=2.5) +
            geom_hline(yintercept=yintercept, color = "green", size=2.5)
        
        ggsave(plotPath, p)
        # cowplot::save_plot(plotPath, p)

    }

}

# ------------------------------------
# Get plot sequence
paramsDf = read.csv("./inputs/params.csv")

rankDf = read.csv("../rank_plotting/output/rankDf.csv") |>
    dplyr::left_join(paramsDf, by="simKey")

# rankDf = rankDf[1:1,]

for(rank in sort(rankDf$rank)){

    paramsRow = rankDf[rankDf$rank==rank,]

    plotPath = file.path("./plots", paste0("rank_", sprintf("%06d", rank), ".png"))

    bigDfPath = "./inputs/results_summary_fixed_TARGET_MINIMAL.rds"
    passKeysDfPath = "./inputs/passKeys.csv"
    plotDir = "plots"
    plotPrefix = ""
    passKeysDfPredroppedPath = NULL

    plotPosterior(
        bigDfPath=bigDfPath,
        passKeysDfPath=passKeysDfPath,
        plotDir=plotDir,
        plotPrefix=plotPrefix,
        plotPath=plotPath,
        passKeysDfPredroppedPath=passKeysDfPredroppedPath,
        paramsRow=paramsRow
    )

}

