library(ggplot2)
library(ggpubr)

tempFunc = function(
    initTemp,
    step,
    kMax
){

    k = seq(1, kMax)
    Temp = initTemp * (1 - step)^k

    return(Temp)
}

initTempVec = c(1, 10, 100, 1000)
stepVec = c(0.1, 0.01, 0.001, 0.0001)
kMax = 15000
# kMax = 15
rewardRatio = 0.95


resDfList = list()

plotList = list()

i = 0
for(initTemp in initTempVec){

    print(initTemp)

    for(step in stepVec){

        print(step)

        tempRaw = tempFunc(
            initTemp=initTemp,
            step=step,
            kMax=kMax
        )
        
        temp = tempRaw / initTemp

        blueVals = exp(-(rewardRatio/tempRaw))
        greenVals = exp(-((1-rewardRatio)/tempRaw))

        thisResDf = data.frame(
            i=i,
            kMax=kMax,
            initTemp=initTemp,
            step=step,
            temp=temp,
            blueVals=blueVals,
            greenVals=greenVals,
            iStep = seq(1, kMax)
        )
        
        title = paste0(i, " / initTemp: ", initTemp, " / step: ", step)
        
        p = ggplot(thisResDf, aes(x=iStep, y=temp)) + 
            geom_line(color='red') +
            geom_line(aes(x=iStep,y=blueVals),color='blue') +
            geom_line(aes(x=iStep,y=greenVals),color='green') +
            ggtitle(title)
        
        # print(p)
        
        plotList[[as.character(i)]] = p
        
        resDfList[[as.character(i)]] = thisResDf

        i = i + 1
    }

}

# resDf = dplyr::bind_rows(resDfList)
# 
# thisResDf = resDfList[["0"]]

q = ggarrange(plotlist = plotList, ncol=4, nrow = 4)
q
# ggsave
