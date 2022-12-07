box::use(../../utils/sa)

# countryCode = "CMR"
# inputsKey = "cc_CMR_year_0"
# dropAnyYearsBool = FALSE


# countryCode = "NGA"
# inputsKey = "cc_NGA_year_0"
# dropAnyYearsBool = TRUE
# dropYearsVec = c(2017)


countryCode = "NGA"
inputsKey = "di_NGA_year_1"
dropAnyYearsBool = TRUE
dropYearsVec = c(2017)

# -------------------------------------------------
rewardRatio = 1
detectionProbVec = c(0.01, 0.1, 0.25, 0.5, 0.75, 0.85, 1)

outDir = file.path("outputs", inputsKey)
dir.create(outDir, showWarnings = FALSE, recursive = TRUE)

# -------------------------------------------------

surveyDf = sf::read_sf("../../../../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.gpkg") |>
    dplyr::filter(country_code == countryCode)

# Read in host raster
hostRaster = raster::raster("../../../inputs/inputs_scenarios/2022_03_15_cross_continental_endemic/inputs/L_0_HOSTDENSITY.txt")

count = 0
outDfList = list()
mapList = list()
for(targetYear in sort(unique(surveyDf$year))){
    
    # Split by year
    surveyDfYear = surveyDf[surveyDf$year == targetYear,]
    
    coordsDf = surveyDfYear |>
        sf::st_drop_geometry() |>
        dplyr::select(longitude, latitude) |>
        dplyr::rename(x=longitude, y=latitude) |>
        as.data.frame()
    
    m = mapview::mapview(surveyDfYear)
    mapList[[as.character(targetYear)]] = m
    
    # ----------------------------------------------
    inputsDir = here::here("surveillance/inputs/inf_rasters_processed", inputsKey, "outputs")
    infBrickPath = file.path(inputsDir, "brick.tif")
    infBrick = raster::brick(infBrickPath)
    
    
    cellIndexVec = raster::cellFromXY(object=infBrick[[1]], xy=coordsDf)
    
    brickValsDf = as.data.frame(infBrick[cellIndexVec])
    
    for(detectionProb in detectionProbVec){
        
        print(count)
        
        # Calc obj func
        objVal = sa$objectiveFunc(
            brickValsDf=brickValsDf, 
            rewardRatio=rewardRatio,
            detectionProb=detectionProb
        )
        
        outDfList[[as.character(count)]] = data.frame(
            inputsKey=inputsKey,
            targetYear=targetYear,
            numSurveys=nrow(coordsDf),
            detectionProb=detectionProb,
            objVal=objVal
        )
        
        count = count + 1
        
    }
    
}

outDf = dplyr::bind_rows(outDfList)


# Drop 2017 so only one with numSurveys ~ 500
if(dropAnyYearsBool){
    subsetDf = outDf |>
        dplyr::filter(outDf$targetYear != dropYearsVec)
}else{
    subsetDf = outDf
}

p = plotly::plot_ly() |> 
    plotly::add_trace(data = subsetDf,  x=~numSurveys, y=~detectionProb, z=~objVal, type="mesh3d") |>
    plotly::add_trace(data = subsetDf, x=~numSurveys, y=~detectionProb, z=~objVal, mode = "markers", type = "scatter3d", marker = list(size = 5, color = "red", symbol = 104))

# -----------------------------

outDfPath = file.path(outDir, "realWorldSurveyPerformance.csv")
write.csv(outDf, outDfPath, row.names=FALSE)

outPath = file.path(outDir, "sweep_surface.html")
htmlwidgets::saveWidget(p, outPath, selfcontained = T)


