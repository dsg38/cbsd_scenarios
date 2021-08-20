propYearDf = read.csv("../plots/propYearDf.csv")

passDf = propYearDf[propYearDf$POLY_ID=="NGA" & propYearDf$prop==0 & propYearDf$raster_year<=2045,]

# Build year mapping df
rowList = list()
for(iRow in seq_len(nrow(passDf))){
    
    thisRow = passDf[iRow,]
    
    startYear = thisRow$raster_year
    startYearZero = 0
    
    for(j in seq(0, 4)){
        
        thisOutRow = data.frame(
            job=thisRow$job,
            batch=thisRow$batch,
            raster_year=startYear,
            raster_year_zero_index=startYearZero
        )
        
        startYear = startYear + 1
        startYearZero = startYearZero + 1
        
        key = paste0(iRow, "-", j)
        
        rowList[[key]] = thisOutRow

    }
    
}

yearMappingDf = dplyr::bind_rows(rowList)

# Save both
write.csv(passDf, "./outputs/2021_03_26_cross_continental/sim_subset/nga_arrival.csv", row.names=FALSE)
write.csv(yearMappingDf, "./outputs/2021_03_26_cross_continental/sim_subset/year_mapping.csv", row.names=FALSE)
