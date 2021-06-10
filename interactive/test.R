library(leaflet)
library(plainview)
library(leafem)
poppendorf = raster::raster("./data/host_num_fields_uga.tif")

leaflet() %>%
  addProviderTiles("OpenStreetMap") %>%
  addRasterImage(poppendorf, project = TRUE, group = "poppendorf",
                 layerId = "poppendorf") %>%
  addImageQuery(poppendorf[[1]], project = TRUE,
                layerId = "poppendorf") %>%
  addLayersControl(overlayGroups = "poppendorf")
