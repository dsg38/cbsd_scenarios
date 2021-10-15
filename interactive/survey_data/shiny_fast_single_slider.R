library(shiny)
library(leaflet)
# library(RColorBrewer)

# Read cbsd data
surveyDf = sf::read_sf("../../../cassava_data/data_merged/data/2021_10_01/cassava_data_minimal.gpkg")

# Drop all NAs
surveyDf = surveyDf[!is.na(surveyDf$cbsd_any_bool),]

bbox = sf::st_bbox(surveyDf)

pal = colorFactor(
        palette = c('green', 'red'),
        domain = c(FALSE, TRUE)
)


ui <- bootstrapPage(
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    leafletOutput("map", width = "100%", height = "100%"),
    absolutePanel(top = 10, right = 10,
        # sliderInput("range", "Magnitudes", min(surveyDf$year), max(surveyDf$year), sep="",
        #     value = range(surveyDf$year), 
        #    step = 1,
        #     dragRange=TRUE,
        #     animate=list(interval=2000)
        # )

        sliderInput("integer", "Integer:",
            min(surveyDf$year), max(surveyDf$year),
            step = 1,
            sep="",
            value = min(surveyDf$year),
            animate=list(interval=2000)
        )
    )
)

server <- function(input, output, session) {

    filteredData <- reactive({
            surveyDf[surveyDf$year==input$integer,]
    })

    output$map <- renderLeaflet({
        leaflet(surveyDf) %>% 
            addTiles() %>%
            fitBounds(bbox[["xmin"]], bbox[["ymin"]], bbox[["xmax"]], bbox[["ymax"]])
    })

    observe({
        leafletProxy("map") %>%
            leafgl::clearGlLayers() %>%
            leafgl::addGlPoints(filteredData(), fillColor = ~pal(cbsd_any_bool))
    })

}

shinyApp(ui, server)

