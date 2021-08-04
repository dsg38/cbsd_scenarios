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
    scale_y_continuous(breaks=seq(yearMin, yearMax, 5)) + 
    xlab(NULL) + 
    ylab("Arrival Year") #+
    # theme(axis.text=element_text(size=14), axis.title=element_text(size=14))
p

# ggsave("waz.png")
