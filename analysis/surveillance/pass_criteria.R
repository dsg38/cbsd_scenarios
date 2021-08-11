propYearDf = read.csv("../plots/propYearDf.csv")

passDf = propYearDf[propYearDf$POLY_ID=="NGA" & propYearDf$prop==0 & propYearDf$raster_year<=2045,]

write.csv(passDf, "outputs/nga_arrival.csv", row.names=FALSE)
