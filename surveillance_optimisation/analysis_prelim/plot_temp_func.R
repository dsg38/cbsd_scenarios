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
stepVec = signif(10**(c(-2.5, -3, -3.5, -4)), 2)

kMax = 100000
rewardRatio = 1
# rewardRatio = 0.95

resDfList = list()
plotList = list()

i = 0
for(step in stepVec){

    print(step)

    for(initTemp in initTempVec){

        print(initTemp)

        tempRaw = tempFunc(
            initTemp=initTemp,
            step=step,
            kMax=kMax
        )
        
        temp = tempRaw / initTemp

        blueVals = exp(-(rewardRatio/tempRaw))
        # greenVals = exp(-((1-rewardRatio)/tempRaw))

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
        
        title = paste0("initTemp: ", initTemp, " / step: ", step)
        
        p = ggplot(thisResDf, aes(x=iStep, y=temp)) + 
            geom_line(color='red') +
            geom_line(aes(x=iStep,y=blueVals),color='blue') +
            # geom_line(aes(x=iStep,y=greenVals),color='green') +
            ggtitle(title) +
            theme(
                plot.title = element_text(size=8),
                axis.title = element_text(size=8),
                axis.text =  element_text(size=6)
            )
        
        plotList[[as.character(i)]] = p
        
        resDfList[[as.character(i)]] = thisResDf

        i = i + 1
    }

}

q = ggarrange(plotlist = plotList, ncol=4, nrow = 5)
# q
ggsave("temp_sweep.png")
