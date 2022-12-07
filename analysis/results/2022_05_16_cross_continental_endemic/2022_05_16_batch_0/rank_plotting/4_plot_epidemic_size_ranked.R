box::use(ggplot2[...])

rankDf = read.csv("./output/rankDf.csv")

p = ggplot(rankDf, aes(x=rank, y=numFieldsInf, colour=ngaBool)) +
    geom_point() +
    xlab("Rank by number of infected fields in 2050") +
    ylab("Number of infected fields in 2050") +
    labs(colour="Epidemic in\nNigeria by\n2050")
    

# p

# sum(rankDf$ngaBool)

outPath = "./plots_size/NGA.png"
dir.create(dirname(outPath), recursive = TRUE, showWarnings = FALSE)

ggsave(filename = outPath, plot = p)