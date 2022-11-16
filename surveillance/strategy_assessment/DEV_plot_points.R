box::use(ggplot2[...])

resDf = read.csv("./data/pointsDf.csv") |>
    dplyr::filter(numSurveysTrained==1000)

resDf$detectionProbTest = as.factor(resDf$detectionProbTest)
resDf$detectionProbTrained = as.factor(resDf$detectionProbTrained)

p = ggplot(data=resDf, aes(x=detectionProbTrained, y=objVal, colour=detectionProbTest, group=detectionProbTest)) +
    geom_point() +
    geom_line()
# p

outDir = "./plots"
dir.create(outDir, showWarnings = FALSE, recursive = TRUE)

outPathP = file.path(outDir, "points_sweep_trained.png")
ggsave(filename=outPathP, plot=p)


q = ggplot(data=resDf, aes(x=detectionProbTest, y=objVal, colour=detectionProbTrained, group=detectionProbTrained)) +
    geom_point() +
    geom_line()

# q

outPathQ = file.path(outDir, "points_sweep_test.png")
ggsave(filename=outPathQ, plot=q)
