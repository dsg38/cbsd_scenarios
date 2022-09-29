library(ggplot2)
library(ggpubr)

iMax = 15

plotDir = './plots/'

plotList = list()
for(i in seq(0, iMax)){
    
    print(i)

    sweepStr = paste0("sweep_", i)

    resultsDir = file.path("./results/", sweepStr)
    traceDfPath = file.path(resultsDir, "traceDf.rds")
    configPath = file.path(resultsDir, "config.json")
    
    # if(file.exists(traceDfPath)){
        
        
    traceDf = readRDS(traceDfPath)
    
    # Optional step to only plot subset of obj vals for clarity
    filterBool = traceDf$iteration %% 100 == 0
    traceDfSubset = traceDf[filterBool,]
    
    # Get param data
    configList = jsonlite::read_json(path=configPath)
    title = paste0("initTemp: ", configList$initTemp, " / step: ", configList$step, " / i:", i)
    
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

    q = ggplot(traceDfSubset, aes(x=iteration, y=objective_func_val)) + 
        geom_line(color='black', lwd=2) +
        geom_line(data=traceDf, aes(x=iteration,y=prop_worst_move_A),color='blue', lwd=2) +
        geom_line(data=traceDf, aes(x=iteration,y=temp),color='red', lwd=2) +
        ylim(0, 1) +
        theme(
            legend.position = "none",
            axis.text=element_text(size=20),
            axis.title=element_text(size=20),
            plot.margin = margin(10, 20, 10, 10)
        )
    
    # Save individual plots
    ggsave(filename = file.path(plotDir, paste0(sweepStr, ".png")), plot = q)

    # }else{
    #     print("MISSING:")
    #     print(traceDfPath)
    # }

}


# Save grid
r = ggarrange(plotlist = plotList, ncol=4, nrow = 5)

ggsave(filename = file.path(plotDir, "sweep_grid.png"), plot = r)
