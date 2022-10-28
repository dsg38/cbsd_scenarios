box::use(ggplot2[...])

rankDf = read.csv("../../../analysis/results/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/rank_plotting/output/rankDf.csv")

p = ggplot(rankDf, aes(x=rank, y=numFieldsInf, colour=ngaBool)) +
    geom_point()

p

randRow = rankDf |>
    dplyr::sample_n(1)

# "2022_05_16_cross_continental_endemic-2022_05_16_batch_0-job362-0"
print(randRow$simKey)
