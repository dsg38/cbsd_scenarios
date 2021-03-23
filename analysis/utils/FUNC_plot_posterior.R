library(ggplot2)
library(dplyr)
library(raster)
library(ggspatial)
library(rasterVis)

plotPosteriorDimension = function(
  bigDf,
  bigDfPass,
  xKey,
  yKey,
  plotExtent=NULL,
  plotTitle=NULL,
  yintercept=NULL,
  xintercept=NULL
){
  
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
    resolution=c(0.05)
  )
  
  sampleRaster = rasterize(sampleDf, templateRaster, fun="count")
  passRaster = rasterize(passDf, templateRaster, fun="count")
  
  # Calc normalised pass raster
  passRateRaster = passRaster / sampleRaster
  
  # Plot
  p = gplot(passRateRaster) +
    geom_tile(aes(fill = value)) +
    scale_fill_continuous(na.value="transparent") +
    geom_polygon(data = hull, aes_string(x=xKey, y=yKey), alpha = 0.2) +
    xlab(xKey) +
    ylab(yKey) +
    ggtitle(plotTitle)
  
  if(!is.null(yintercept)){
    p = p + 
      geom_hline(yintercept=yintercept, color = "green", size=1.1)
  }

  if(!is.null(xintercept)){
    p = p + 
      geom_vline(xintercept=xintercept, color = "green", size=1.1)
  }

  if(!is.null(plotExtent)){
    p = p +
      xlim(plotExtent$xmin, plotExtent$xmax) +
      ylim(plotExtent$ymin, plotExtent$ymax)
  }
  
  return(p)
  
}



plotPosterior = function(
  bigMinimalDfRaw,
  passKeysDf,
  plotDir,
  plotTitle=NULL,
  paramsPath=NULL
  ){

  passKeys = passKeysDf$passKeys

  keepColumns = c("simKey", "Kernel_0_Parameter", "Kernel_0_WithinCellProportion", "Rate_0_Sporulation")

  bigMinimalDf = unique(bigMinimalDfRaw[,keepColumns])

  # Append log beta
  logBeta = log(bigMinimalDf$Rate_0_Sporulation)

  # Append pass boolean to each sim
  passBool = bigMinimalDf$simKey %in% passKeys

  bigDf = cbind(bigMinimalDf, logBeta, passBool)

  # Extract subset that passes
  bigDfPass = bigDf[bigDf$passBool==TRUE,]

  keyKernalAlpha = "Kernel_0_Parameter"
  keyLogBeta = "logBeta"
  keyKernelP = "Kernel_0_WithinCellProportion"

  # plotExtent = list(
  #   xmin=3,
  #   xmax=4.5,
  #   ymin=5,
  #   ymax=6.8
  # )

  keyKernalAlphaVal = NULL
  keyLogBetaVal = NULL
  keyKernelPVal = NULL
  if(!is.null(paramsPath)){
    
    paramsDf = read.csv(paramsPath)

    keyKernalAlphaVal = paramsDf[paramsDf$param_name==keyKernalAlpha,c("param_val")]
    keyLogBetaVal = paramsDf[paramsDf$param_name=="Rate_0_Sporulation",c("param_val")]
    keyKernelPVal = paramsDf[paramsDf$param_name==keyKernelP,c("param_val")]

  }

  print("plotA")
  # print("keyLogBetaVal")
  # print(keyLogBetaVal)
  # print("keyKernalAlphaVal")
  # print(keyKernalAlphaVal)
  plotA = plotPosteriorDimension(
    bigDf=bigDf,
    bigDfPass=bigDfPass,
    xKey=keyKernalAlpha,
    yKey=keyLogBeta,
    plotTitle=plotTitle,
    yintercept=keyLogBetaVal,
    xintercept=keyKernalAlphaVal
  )

  outPathA = file.path(plotDir, "plotA.png")
  suppressMessages(ggsave(outPathA))

  # ---------------------------------

  print("plotB")
  # print("keyKernelPVal")
  # print(keyKernelPVal)
  # print("keyKernalAlphaVal")
  # print(keyKernalAlphaVal)
  plotB = plotPosteriorDimension(
    bigDf=bigDf,
    bigDfPass=bigDfPass,
    xKey=keyKernalAlpha,
    yKey=keyKernelP,
    plotTitle=plotTitle,
    yintercept=keyKernelPVal,
    xintercept=keyKernalAlphaVal
  )

  outPathB = file.path(plotDir, "plotB.png")
  suppressMessages(ggsave(outPathB))

  # ---------------------------------

  print("plotC")
  # print("keyKernelPVal")
  # print(keyKernelPVal)
  # print("keyLogBetaVal")
  # print(keyLogBetaVal)
  plotC = plotPosteriorDimension(
    bigDf=bigDf,
    bigDfPass=bigDfPass,
    xKey=keyLogBeta,
    yKey=keyKernelP,
    plotTitle=plotTitle,
    yintercept=keyKernelPVal,
    xintercept=keyLogBetaVal
  )
  
  outPathC = file.path(plotDir, "plotC.png")
  suppressMessages(ggsave(outPathC))

}
