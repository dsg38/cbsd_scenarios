args = commandArgs(trailingOnly=TRUE)

# configPath = args[[1]]

# b = args[[2]]

# c = args[[3]]

progDf = read.csv("./simulations/sim_output/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/progress.csv")

x = progDf[1:10,]
y = progDf[11:20,]

a = c(1, 2, 3, 4, 5)

a[1:5]
length(a)
