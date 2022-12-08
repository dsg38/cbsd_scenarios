box::use(ggplot2[...])

rankDf = read.csv("./output/rankDf.csv")

cols = c("TRUE"="#00B8BA","FALSE"="#FF5254")

p = ggplot(rankDf, aes(x=rank, y=numFieldsInf, colour=ngaBool)) +
    geom_point() +
    xlab("Rank by number of infected fields in 2050") +
    ylab("Number of infected fields in 2050") +
    labs(colour="Epidemic\nin NGA by\n2050") + 
    scale_colour_manual(values=cols)

outPath = "./plots_bool_all/NGA.png"
dir.create(dirname(outPath), recursive = TRUE, showWarnings = FALSE)

cowplot::save_plot(filename = outPath, plot = p)

sum(rankDf$ngaBool) / nrow(rankDf)



# p = ggplot(rankDf, aes(x=rank, y=numFieldsInf, colour=cmrBool)) +
#     geom_point() +
#     xlab("Rank by number of infected fields in 2050") +
#     ylab("Number of infected fields in 2050") +
#     labs(colour="Epidemic in \nX by\n2050") + 
#     ggtitle("CMR")
    
# p

# p = ggplot(rankDf, aes(x=rank, y=numFieldsInf, colour=cafBool)) +
#     geom_point() +
#     xlab("Rank by number of infected fields in 2050") +
#     ylab("Number of infected fields in 2050") +
#     labs(colour="Epidemic in \nX by\n2050") + 
#     ggtitle("CAF")
    
# p

# p = ggplot(rankDf, aes(x=rank, y=numFieldsInf, colour=cogBool)) +
#     geom_point() +
#     xlab("Rank by number of infected fields in 2050") +
#     ylab("Number of infected fields in 2050") +
#     labs(colour="Epidemic in \nX by\n2050") + 
#     ggtitle("COG")
    
# p

# p = ggplot(rankDf, aes(x=rank, y=numFieldsInf, colour=gabBool)) +
#     geom_point() +
#     xlab("Rank by number of infected fields in 2050") +
#     ylab("Number of infected fields in 2050") +
#     labs(colour="Epidemic in \nX by\n2050") + 
#     ggtitle("GAB")
    
# p

# p = ggplot(rankDf, aes(x=rank, y=numFieldsInf, colour=civBool)) +
#     geom_point() +
#     xlab("Rank by number of infected fields in 2050") +
#     ylab("Number of infected fields in 2050") +
#     labs(colour="Epidemic in \nX by\n2050") + 
#     ggtitle("CIV")

# p





