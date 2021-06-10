box::use(leaflet[...])

r = raster::raster("data/host_num_fields_uga.tif")

pal = colorNumeric(c("#0C2C84", "#41B6C4", "#FFFFCC"), raster::values(r), na.color = "transparent", reverse = TRUE)

pal = colorBin("Blues", raster::values(r), 20, pretty=FALSE)

leaflet() %>% addTiles() %>%
    addRasterImage(r, colors = pal, opacity = 0.8)
