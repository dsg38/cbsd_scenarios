propYearDfRaw = read.csv("./results/2021_10_15_endemic_seed/2021_10_15_batch_0/output/propYearDf.csv")

x = propYearDfRaw[propYearDfRaw$POLY_ID=="ZWE" & propYearDfRaw$prop==0,]


hist(x$raster_year)
