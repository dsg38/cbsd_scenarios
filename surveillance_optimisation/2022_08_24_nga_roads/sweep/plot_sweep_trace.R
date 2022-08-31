library(ggplot2)
library(ggpubr)

plotList = list()
for(i in seq(0, 15)){
    
    print(i)

    resultsDir = file.path("./results/", paste0("sweep_", i))
    traceDfPath = file.path(resultsDir, "traceDf.rds")
    configPath = file.path(resultsDir, "config.json")

    traceDf = readRDS(traceDfPath)

    # Optional step to only plot subset of obj vals for clarity
    filterBool = traceDf$iteration %% 100 == 0
    traceDfSubset = traceDf[filterBool,]

    # Get param data
    configList = jsonlite::read_json(path=configPath)
    title = paste0("initTemp: ", configList$initTemp, " / step: ", configList$step)

    p = ggplot(traceDfSubset, aes(x=iteration, y=objective_func_val)) + 
        geom_line(color='black') +
        geom_line(data=traceDf, aes(x=iteration,y=prop_worst_move_A),color='blue') +
        geom_line(data=traceDf, aes(x=iteration,y=temp),color='red') +
        ylim(0, 1) +
        ggtitle(title) +
        theme(
            plot.title = element_text(size=6),
            axis.title = element_text(size=6),
            axis.text =  element_text(size=6)
        )

    plotList[[as.character(i)]] = p

}


q = ggarrange(plotlist = plotList, ncol=4, nrow = 5)

ggsave("sweep.png")
