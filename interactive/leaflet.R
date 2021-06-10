library(leaflet)
library(leafem)
library(plainview)

r = raster::raster("data/host_num_fields.tif")

r[r==0] = NA

bins = c(0, 10, 50, 100, 500, 1000, 10000, 100000)

pal = colorBin("Greens", bins=bins, na.color = "transparent")

leaflet() %>% 
    addTiles() %>%
    addRasterImage(r, layerId = "host", group = "host", colors = pal, opacity = 0.5) %>%
    addMouseCoordinates() %>%
    addImageQuery(r, type="mousemove", layerId = "host", digits=0, position = "bottomleft") %>%
    addLegend(pal = pal, values = raster::values(r), title = "Number of fields") %>%
    addLayersControl(overlayGroups = "host", options = layersControlOptions(collapsed = FALSE))
