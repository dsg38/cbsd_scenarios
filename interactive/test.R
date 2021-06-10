library(leaflet.extras2)

surveyDf = sf::read_sf("./data/survey_data.gpkg")

data = sf::st_cast(surveyDf, "POINT")
data = data[1:1000,]

# pal = colorNumeric(c("#0C2C84", "#41B6C4", "#FFFFCC"), raster::values(r), na.color = "transparent", reverse = TRUE)
#
# pal = colorBin("Blues", raster::values(r), 20, pretty=FALSE)
data$time = lubridate::make_datetime(year=data$year)

leaflet() %>%
    addTiles() %>%
    addTimeslider(data,  options = timesliderOptions(position = "topright", follow=TRUE))


# library(leaflet)
# library(leaflet.extras2)
# library(sf)
# library(geojsonsf)
# 
# data <- sf::st_as_sf(leaflet::atlStorms2005[1,])
# data <- st_cast(data, "POINT")
# data$time = as.POSIXct(
#     seq.POSIXt(Sys.time() - 1000, Sys.time(), length.out = nrow(data)))
# 
# leaflet() %>%
#     addTiles() %>%
#     addTimeslider(data = data,
#                   options = timesliderOptions(
#                       position = "topright",
#                       timeAttribute = "time",
#                       range = TRUE)) %>%
#     setView(-72, 22, 4)
