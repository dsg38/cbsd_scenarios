library(leaflet)
library(leafem)
library(plainview)
library(htmlwidgets)

# Read host and set zero to NA
h = raster::raster("data/host_num_fields.tif")
h[h==0] = NA

# Define host colour pal
bins_host = c(0, 10, 50, 100, 500, 1000, 10000, 100000)
pal_host = colorBin("Greens", bins=bins_host, na.color = "transparent")

# Read vec and set host to NA
v = raster::raster("data/vector.tif")

# Define vec pal
pal_vec = colorNumeric("Spectral", raster::values(v), na.color = "transparent", reverse = TRUE)

l = leaflet() %>%
    # Add base map
    addTiles() %>%
    # Add host
    addRasterImage(h, layerId = "host", group = "host", colors = pal_host, opacity = 0.5) %>%
    addLegend(pal = pal_host, values = raster::values(h), title = "Number of fields") %>%
    # Add vector
    addRasterImage(v, layerId = "vector", group = "vector", opacity = 0.5, colors=pal_vec) %>%
    addLegend(pal = pal_vec, values = raster::values(v), title = "Surface temp") %>%
    # Add toggle layers control
    addLayersControl(overlayGroups = c("host", "vector"), options = layersControlOptions(collapsed = FALSE)) %>%
    hideGroup("vector") %>%
    # Add on hover data
    addMouseCoordinates() %>%
    addImageQuery(h, type="mousemove", layerId = "host", digits=0, position = "bottomleft") %>%
    addImageQuery(v, type="mousemove", layerId = "vector", digits=3, position = "bottomleft")

saveWidget(l, 'map.html')
