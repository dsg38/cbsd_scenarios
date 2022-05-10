library(rworldmap)
library(dplyr)
library(rgdal)
library(rgeos)
library(raster)
projStr = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"

countryPolys = getMap(resolution = "high")
uga_poly_df = countryPolys[countryPolys@data$ADM0_A3=="UGA",]

# -----------------------------
# Gen grid polys
nBreaks = 5

xDiff = xmax(uga_poly_df) - xmin(uga_poly_df)
yDiff = ymax(uga_poly_df) - ymin(uga_poly_df)

dx = xDiff / nBreaks
dy = yDiff / nBreaks

thisXmin = xmin(uga_poly_df)
thisYmin = ymin(uga_poly_df)

chunkCount = 0
firstGrid = TRUE
for(i in 1:nBreaks){
  
  for(j in 1:nBreaks){
    
    chunkName = paste0("mask_uga_grid_", chunkCount)
    
    thisExtent = extent(thisXmin, thisXmin + dx, thisYmin, thisYmin + dy)
    
    thisExtentSp = as(thisExtent, 'SpatialPolygons')
    thisExtentSpDf = SpatialPolygonsDataFrame(thisExtentSp, data=data.frame(ID=chunkName))
    proj4string(thisExtentSpDf) = projStr
    
    chunkOutUga = over(uga_poly_df, thisExtentSpDf)
    chunkOutUgaBool = is.na(chunkOutUga[1,1])
    
    if(!chunkOutUgaBool){

        if(firstGrid){
            allPolyDf = sf::st_as_sf(thisExtentSpDf)
            firstGrid = FALSE
        }else{
            allPolyDf = rbind(allPolyDf, sf::st_as_sf(thisExtentSpDf))
        }
    }
    
    thisYmin = thisYmin + dy
    chunkCount = chunkCount + 1
    
  }
  
  thisYmin = ymin(uga_poly_df)
  thisXmin = thisXmin + dx
  
}

x = allPolyDf |>
    dplyr::rename(POLY_ID=ID)

sf::write_sf(x, "./custom_polys/mask_grids.geojson")
