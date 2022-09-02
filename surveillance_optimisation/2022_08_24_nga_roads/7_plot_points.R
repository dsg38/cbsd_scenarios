library(tictoc)
library(tmap)
tmap_options(show.messages=FALSE)

resultsDir = "./sweep/results/sweep_4/"
sumRasterPath = "./data/sumRasterMask.tif"
countryPolysDfPath = "../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg"

plotDir = "./plots/sweep_4/points/"

# Define what interval of plots to plot (i.e. 1 = plot all)
plotFactor = 100
downscaleBool = FALSE

# --------------------------

dir.create(plotDir, showWarnings = FALSE, recursive = TRUE)

coordsDf = readRDS(file.path(resultsDir, "coordsDf.rds"))

sumRaster = raster::raster(sumRasterPath)

# TEMP: Downscale raster for plotting speed
if(downscaleBool){
    sumRaster = raster::aggregate(sumRaster, 2)
}

# Set all zeros to NA
sumRaster[sumRaster==0] = NA

countryPolysDf = sf::read_sf(countryPolysDfPath)
countryPolysDfSimple = sf::st_simplify(countryPolysDf, dTolerance = 1000)

ngaExtent = sf::st_bbox(countryPolysDfSimple |> dplyr::filter(GID_0 == "NGA"))

compareCoords = function(a, b){
    xBool = a$x == b$x
    yBool = a$y == b$y
    
    coordsChangeBool = !(xBool | yBool)
    
    changeDf = cbind(b, coordsChangeBool)
    
    return(changeDf)
}

plotMap = function(changeDf, plotPath){
    
    numChange = sum(changeDf$coordsChangeBool)
    
    changeSf = changeDf |>
        sf::st_as_sf(coords=c("x", "y"), crs="WGS84")
    
    p = tm_shape(sumRaster, bbox=ngaExtent) +
        tm_raster(palette="Reds") +
        tm_shape(changeSf) +
        tm_dots(size=0.03, col="coordsChangeBool", palette=c("TRUE"='green', "FALSE"='black')) +
        tm_shape(countryPolysDfSimple) +
        tm_borders(lwd=0.5) +
        tm_layout(
            main.title=paste0("Iteration: ", changeDf$iteration[[1]], " - Num change: ", numChange),
            legend.position = c("right", "top")
        )
    # p
    # browser()
    tmap_save(p, plotPath)
}


iMax = max(coordsDf$iteration)
plotSeq = seq(1, iMax, by=plotFactor)

print("NUM TO PLOT:")
print(length(plotSeq))

tic()
for(i in plotSeq){
    
    print(i)
    
    if(i==1){
        a = coordsDf[coordsDf$iteration==1,]
        b = coordsDf[coordsDf$iteration==1,]
    }else{
        a = coordsDf[coordsDf$iteration==i-1,]
        b = coordsDf[coordsDf$iteration==i,]
    }
    
    changeDf = compareCoords(a=a, b=b)
    
    iStr = sprintf("%06d", i)
    
    plotPath = file.path(plotDir, paste0("plot_", iStr, ".png"))
    
    plotMap(changeDf=changeDf, plotPath=plotPath)
    
}
toc()
