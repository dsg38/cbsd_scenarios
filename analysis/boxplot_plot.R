box::use(ggplot2[...])

arrivalDf = read.csv("./plots/arrivalDf.csv")

infReplaceVal = 5000
yearMin = 2004
yearMax = 2054

# Replace infs
arrivalDf$arrival_year[is.infinite(arrivalDf$arrival_year)] = infReplaceVal

# Decide order
plottingPriority = reorder(arrivalDf[,"POLY_ID"], arrivalDf[,"arrival_year"], FUN=quantile, probs=0.75)

p = ggplot(arrivalDf, aes(x=plottingPriority, y=arrival_year)) + 
    geom_boxplot() + 
    coord_flip(ylim=c(yearMin, yearMax)) + 
    scale_y_continuous(breaks=seq(yearMin, yearMax, 5))
p


# p = ggplot(summaryDf, aes(x = myOrder, y = summaryDf[,whichCol]+startYear)) + geom_boxplot()
# # p = p + geom_hline(yintercept=2019, linetype="dashed", color = "red")
# p = p + coord_flip(ylim=c(plotYearMin, plotYearMax)) + scale_y_continuous(breaks=seq(plotYearMin, plotYearMax, 5))
# p = p + ylab(stringBarplot) + xlab("")
# p = p + theme(axis.text=element_text(size=14), axis.title=element_text(size=14))
# # p = p + theme(axis.text=element_text(size=14))
# 
# ggsave(outPathBoxplot)#, scale=0.7)#, dpi=600)
