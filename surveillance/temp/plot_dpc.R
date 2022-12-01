box::use(ggplot2[...])

bigDf = readRDS("./data/bigDf.rds")

bigDf_1 = bigDf[bigDf$Time==1,]
bigDf_2 = bigDf[bigDf$Time==2,]
polyDf = read.csv("../inputs/inf_rasters/cc_NGA_year_0/polyDf.csv")

xMin = -1E6/30

p = ggplot(bigDf_1, aes(x=nPopulationsInfected_0)) + 
    geom_histogram(color="black", fill="white") +
    ggtitle(paste0("d1: ", round(median(bigDf_1$nPopulationsInfected_0), 1))) +
    scale_x_continuous(limits = c(xMin, max(polyDf$raster_num_fields)))

p

# -----------------------

p = ggplot(bigDf_2, aes(x=nPopulationsInfected_0)) + 
    geom_histogram(color="black", fill="white") +
    ggtitle(paste0("d2: ", round(median(bigDf_2$nPopulationsInfected_0), 1))) +
    scale_x_continuous(limits = c(xMin, max(polyDf$raster_num_fields)))

p
# 
# median(bigDf_2$nPopulationsInfected_0)
# max(bigDf_2$nPopulationsInfected_0)

# -----------------------



p = ggplot(polyDf, aes(x=raster_num_fields)) + 
    geom_histogram(color="black", fill="white") +
    ggtitle(paste0("cc0: ", round(median(polyDf$raster_num_fields), 1))) +
    scale_x_continuous(limits = c(xMin, max(polyDf$raster_num_fields)))

p

# median(polyDf$raster_num_fields)
