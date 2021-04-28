library(ggplot2)
library(ggfan)

resultsDir = "./results/2021_03_26_cross_continental/2021_03_29_batch_0/"

resultsDf = readRDS(file.path(resultsDir, "results_summary_fixed_TARGET.rds"))

# --------------------------------------

drcNameOptions = c(
    "2017_mask_drc_central_small",
    "2017_mask_drc_central_big",
    "2017_mask_drc_nw",
    "2017_mask_drc_central_south"
)

getDrcPassKeys = function(resultsDf, drcPolyKey, tolerance=NULL){
    
    passDf = resultsDf[(resultsDf$polyName == drcPolyKey) & (resultsDf$nPos>0),]
    
    return(passDf)
    
}

passDfDrc = getDrcPassKeys(resultsDf, "2017_mask_drc_central_small")

# ------------------------------------------

plotInfProp = function(thisResultsDf, title, outPath){
    
    thisResultsDf$surveyDataYear = as.numeric(thisResultsDf$surveyDataYear)
    
    tolMin = thisResultsDf$targetVal - tolerance
    tolMin[tolMin<0] = 0
    
    tolMax = thisResultsDf$targetVal + tolerance
    tolMax[tolMax>1] = 1
    
    targetDf = unique(data.frame(
        surveyDataYear=thisResultsDf$surveyDataYear,
        targetVal=thisResultsDf$targetVal,
        tolMin=tolMin,
        tolMax=tolMax
    ))
    
    p = ggplot(data=thisResultsDf, aes(x=surveyDataYear, y=infProp)) +
        geom_fan(intervals = seq(0,1,0.2)) +
        scale_fill_gradient(low="#5D5DF8", high="#C1C1EF") +
        ylim(0,1)+
        geom_line(data=targetDf, aes(x=surveyDataYear, y=targetVal), color="red")+
        geom_point(data=targetDf, aes(x=surveyDataYear, y=targetVal), color="red", fill="red")+
        geom_point(data=targetDf, aes(x=surveyDataYear, y=tolMax), color="green", shape=25, fill="green") +
        geom_point(data=targetDf, aes(x=surveyDataYear, y=tolMin), color="green", shape=24, fill="green") +
        ggtitle(title)
    
    ggsave(outPath)
    
}


getUgaPassKeys = function(resultsDf, tolerance){
    
    maskVec = c("mask_uga_hole", "mask_uga_kam")
    passKeysList = list()
    for(thisMask in maskVec){
        
        print(thisMask)
        
        thisMaskDf = resultsDf[resultsDf$polySuffix==thisMask,]
        dropDf = thisMaskDf[abs(thisMaskDf$targetDiff)>tolerance,]
        
        dropKeys = unique(thisMaskDf[abs(thisMaskDf$targetDiff)>tolerance, "simKey"])
        
        allPolyKeys = unique(thisMaskDf$simKey)
        passKeysBool = !(allPolyKeys %in% dropKeys)
        passKeys = allPolyKeys[passKeysBool]
        
        passKeysList[[thisMask]] = passKeys
        
        # Plot all without tols
        title = paste0("INDIVIDUAL_", thisMask)
        outPathPlot = file.path(resultsDir, paste0(title, ".png"))
        plotInfProp(thisMaskDf, title, outPathPlot)
        
        # Plot each pass
        passDf = resultsDf[resultsDf$simKey%in%passKeys & resultsDf$polySuffix==thisMask,]
        title = paste0("INDIVIDUAL_", thisMask, "_", tolerance)
        outPathPlot = file.path(resultsDir, paste0(title, ".png"))
        plotInfProp(passDf, title, outPathPlot)
        
        
    }
    
    # Which pass all?
    passKeysCum = Reduce(intersect, passKeysList)
    
    # TODO: Plot pass all
    # thisResultsDf = resultsDf[resultsDf$simKey%in%passKeysCum & resultsDf$polySuffix=="mask_uga_hole",]
    
    
    return(passKeysCum)
    
}

tolerance = 0.3
passKeysAll = getUgaPassKeys(resultsDf, tolerance)

# Which meet DRC and UGA requirements?
# passKeysAll = passKeysUga[passKeysUga %in% passDfDrc$simKey]
# 
passDfAll = resultsDf[resultsDf$simKey%in%passKeysAll,]

length(unique(passDfAll$simKey))
# 
# passDfAllDrc = passDfAll[passDfAll$polyName=="2017_mask_drc_central_small",]



# Which have finished?
progressDf = read.csv("../../stuff.csv")

notDoneDf = progressDf[progressDf$dpcLastSimTime!=2050,]

notDoneDf$jobName[notDoneDf$jobName %in% passDfAll$job]



# yearVec = c()
# for(thisJob in passDfAllDrc$job){
# 
#     thisYear = progressDf[progressDf$job==thisJob,"year"]
#     yearVec = c(yearVec, thisYear)
# }
# 
# finalDf = cbind(passDfAllDrc, simLastYear=yearVec)
# 
# wankDf = finalDf[finalDf$simLastYear>2040,]
# 
# wankDf$job

# finishedDf = progressDf[progressDf$year==2050,]
# 
# passDfAllFinished = passDfAll[passDfAll$job %in% finishedDf$job,]
# 
# passDfAllFinishedDrc = passDfAllFinished[passDfAllFinished$polyName=="2017_mask_drc_central_small",]

# hist(passDfDrc$nPos)
# hist(passDfAllFinishedDrc$nPos)

# SELECTED SIMS
# plotDf = passDfAllFinishedDrc[passDfAllFinishedDrc$nPos==5,]
