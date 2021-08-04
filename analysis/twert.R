x = read.csv("../inputs/process_polys/outputs/country_categories.csv")

keepDf = x[x$waveBool | x$cdpBool | x$interestingBool,]
dropDf = x[!(x$waveBool | x$cdpBool | x$interestingBool),]
