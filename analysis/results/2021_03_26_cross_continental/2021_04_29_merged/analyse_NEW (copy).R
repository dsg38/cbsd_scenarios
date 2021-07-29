box::use(../../../utils_analysis)
# box::reload(utils_analysis)

surveyKeysList = rjson::fromJSON(file="./output/results_sim_survey.json")
infKeysList = rjson::fromJSON(file="./output/results_inf_polys.json")

# names(surveyKeysList)

# Parse NGA arrival times
polysDf = readRDS("./output/raster_poly_stats_agg_minimal.rds")

polysDfNgaRaw = polysDf[polysDf$POLY_ID=="NGA",]

simKeys = paste(polysDfNgaRaw$scenario, polysDfNgaRaw$batch, polysDfNgaRaw$job, "0", sep="-")

polysDfNga = cbind(polysDfNgaRaw, simKey=simKeys)

splitList = split(polysDfNga, polysDfNga$job)


# thisDf = splitList[["job1"]]

outList = list()
for(job in names(splitList)){
    
    thisDf = splitList[[job]]
    
    anyInf = any(thisDf$raster_num_cells_populated > 0)
    
    if(anyInf){
        
        firstYear = min(thisDf[thisDf$raster_num_cells_populated > 0,"raster_year"])
        
        outList[[job]] = thisDf[thisDf$raster_year==firstYear,]
        
    }
    
}

x = dplyr::bind_rows(outList)
x$raster_num_cells_populated > 0
