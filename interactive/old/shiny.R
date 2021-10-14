library(shiny)
library(leaflet)
# library(RColorBrewer)

# Read cbsd data
surveyDf = sf::read_sf("./data/survey_data.gpkg")

bbox = sf::st_bbox(surveyDf)

pal = colorFactor(
        palette = c('green', 'red'),
        domain = c(0, 1)
)


ui <- bootstrapPage(
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    leafletOutput("map", width = "100%", height = "100%"),
    absolutePanel(top = 10, right = 10,
        sliderInput("range", "Magnitudes", min(surveyDf$year), max(surveyDf$year), sep="",
            value = range(surveyDf$year), step = 1,
            dragRange=TRUE,
            animate=list(interval=2000)
        )
    )
)

server <- function(input, output, session) {

    filteredData <- reactive({
            surveyDf[surveyDf$year >= input$range[1] & surveyDf$year <= input$range[2],]
    })

    output$map <- renderLeaflet({
        leaflet(surveyDf) %>% 
            addTiles() %>%
            fitBounds(bbox[["xmin"]], bbox[["ymin"]], bbox[["xmax"]], bbox[["ymax"]])
    })

    observe({
        leafletProxy("map", data = filteredData()) %>%
            clearShapes() %>%
            addCircles(radius = 2500, color = ~pal(cbsd))
    })

}

shinyApp(ui, server)
