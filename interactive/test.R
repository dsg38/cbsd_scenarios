library(shiny)
library(leaflet)

# Read cbsd data
surveyDf = sf::read_sf("./data/survey_data.gpkg")

bbox = sf::st_bbox(surveyDf)

pal = colorFactor(
    palette = c('green', 'red'),
    domain = c(0, 1)
)

leaflet(surveyDf) %>% 
    addTiles() %>%
    fitBounds(bbox[["xmin"]], bbox[["ymin"]], bbox[["xmax"]], bbox[["ymax"]]) %>%
    addCircles(color=~pal(cbsd), radius=2500, fillOpacity=0.5, opacity=0.5)
