library(sf)
library(dplyr)

customPolyPaths = list.files("custom_polys", full.names = TRUE)

polyList = list()
for(customPolyPath in customPolyPaths){
    thisPolySp = readRDS(customPolyPath)
    thisPolySf = st_as_sf(thisPolySp)
    
    polyName = tools::file_path_sans_ext(basename(customPolyPath))
    
    outRow = st_sf(
        GID_0=polyName,
        NAME_0=polyName,
        geom=thisPolySf$geometry
    )
    
    polyList[[customPolyPath]] = outRow
}

polyDf = bind_rows(polyList)

st_write(polyDf, "../inputs_raw/polygons/polys_0/custom_poly_df.gpkg")
