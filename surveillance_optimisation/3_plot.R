library(tmap)
tmap_options(show.messages=FALSE)

coordsDf = read.csv("./data/coordsDf.csv")

countryPolysDf = sf::read_sf("../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg")
countryPolysDfSimple = sf::st_simplify(countryPolysDf, dTolerance = 1000)

ugaExtent = sf::st_bbox(countryPolysDfSimple |> dplyr::filter(GID_0 == "UGA"))

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
    
    p = tm_shape(changeSf, bbox=ugaExtent) + 
        tm_dots(size=0.2, col="coordsChangeBool", palette=c("TRUE"='green', "FALSE"='black')) + 
        tm_shape(countryPolysDfSimple) +
        tm_borders(lwd=0.5) + 
        tm_layout(
            main.title=paste0("Iteration: ", changeDf$iteration[[1]], " - Num change: ", numChange),
            legend.position = c("right", "top")
        )
    
    tmap_save(p, plotPath)
}


iMax = max(coordsDf$iteration)

for(i in seq_len(iMax)){
    
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
    
    plotPath = file.path("./plots/", paste0("plot_", iStr, ".png"))
    
    plotMap(changeDf=changeDf, plotPath=plotPath)
    
}



