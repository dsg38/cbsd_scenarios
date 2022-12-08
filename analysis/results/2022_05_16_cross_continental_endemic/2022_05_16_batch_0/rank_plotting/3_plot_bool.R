box::use(ggplot2[...])

rankDf = read.csv("./output/rankDf.csv")

cols = c("TRUE"="#00B8BA","FALSE"="#FF5254")

for(i in seq_len(nrow(rankDf))){
    
    thisDf = rankDf[1:i,]
        
    p = ggplot(thisDf, aes(x=rank, y=numFieldsInf, colour=ngaBool)) +
        geom_point() +
        xlab("Rank by number of infected fields in 2050") +
        ylab("Number of infected fields in 2050") +
        labs(colour="Epidemic\nin NGA by\n2050") + 
        theme(text = element_text(size=25)) +
        xlim(0, 414) +
        ylim(min(rankDf$numFieldsInf), max(rankDf$numFieldsInf)) +
        scale_colour_manual(values=cols)
    # p
    
    ggsave(file.path("plots_bool", paste0("rank_", sprintf("%06d", i), ".png")), plot=p)
        
}

# p = ggplot(rankDf, aes(x=rank, y=numFieldsInf, colour=ngaBool)) +
#     geom_point() +
#     xlab("Rank by number of infected fields in 2050") +
#     ylab("Number of infected fields in 2050") +
#     labs(colour="Epidemic\nin NGA by\n2050") + 
#     theme(text = element_text(size=25)) +
#     xlim(0, 414)
# 
# # p
# 
# ggsave("stuff.png")



