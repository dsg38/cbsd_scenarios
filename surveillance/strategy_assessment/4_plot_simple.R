
simpleDfPath = "./results/2022_10_07_cc_NGA_year_0/simple_clusters/bigResultsDf_median.rds"
numSurveysTest = 1000

simpleDf = readRDS(simpleDfPath)

# # Plot

# simpleDf$detectionProbTest = as.factor(simpleDf$detectionProbTest)
# simpleDf$detectionProbTrained = as.factor(simpleDf$detectionProbTrained)

# simpleDfSubset = simpleDf[simpleDf$numSurveysTest==numSurveysTest,]

# p = ggplot(data=simpleDfSubset, aes(x=detectionProbTest, y=objVal, colour=detectionProbTrained, group=detectionProbTrained)) +
#     geom_point() +
#     geom_line()

# outPath = file.path(outDir, paste0(simpleType, "_sweep_test.png"))
# ggsave(filename=outPath, plot=p)
