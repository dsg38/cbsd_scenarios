box::use(ggplot2[...])

plotDir = "./plots/flat_3d"
dir.create(plotDir, showWarnings = FALSE, recursive = TRUE)

# ---------------------------

optimalDf = read.csv("./data/optimalDf.csv")
optimalDf$numSurveys = as.factor(optimalDf$numSurveys)

p = ggplot(optimalDf, aes(x=detectionProb, y=objective_func_val, col=numSurveys)) +
    geom_line() +
    geom_point()

ggsave(filename=file.path(plotDir, "flat_numSurveys.png"), plot=p)

# ---------------------------

optimalDf = read.csv("./data/optimalDf.csv")
optimalDf$detectionProb = as.factor(optimalDf$detectionProb)

q = ggplot(optimalDf, aes(x=numSurveys, y=objective_func_val, col=detectionProb)) +
    geom_line() +
    geom_point()

ggsave(filename=file.path(plotDir, "flat_detectionProb.png"), plot=q)


