library(shiny)
library(leaflet)
library(leafem)
library(plainview)
library(htmlwidgets)

# Read cbsd data
surveyDf = sf::read_sf("./data/survey_data.gpkg")

bbox = sf::st_bbox(surveyDf)

pal_survey = colorFactor(
    palette = c('green', 'red'),
    domain = c(0, 1)
)

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

# -----------------------------------------
# Shiny

# Set up shiny ui
ui = bootstrapPage(
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    leafletOutput("map", width = "100%", height = "100%"),
    absolutePanel(bottom = 10, right = 10,
        sliderInput("range", "Magnitudes", min(surveyDf$year), max(surveyDf$year), sep="",
            value = range(surveyDf$year), step = 1,
            dragRange=TRUE,
            animate=list(interval=2000)
        )
    )
)

# Set up shiny server
server = function(input, output, session) {

    filteredData = reactive({
        surveyDf[surveyDf$year >= input$range[1] & surveyDf$year <= input$range[2],]
    })

    output$map = renderLeaflet({
        leaflet(surveyDf) %>% 
            addTiles() %>%
            fitBounds(bbox[["xmin"]], bbox[["ymin"]], bbox[["xmax"]], bbox[["ymax"]]) %>%
            # Add inspector
            addMouseCoordinates() %>%
            addImageQuery(h, type="mousemove", layerId = "host", digits=0, position = "bottomleft") %>%
            addImageQuery(v, type="mousemove", layerId = "vector", digits=3, position = "bottomleft")
    })
    
    # Add host + vector
    observe({
        leafletProxy("map") %>%
            # Add host
            addRasterImage(h, layerId = "host", group = "host", colors = pal_host, opacity = 0.5) %>%
            addLegend(pal = pal_host, values = raster::values(h), title = "Number of fields") %>%
            # Add vector
            addRasterImage(v, layerId = "vector", group = "vector", opacity = 0.5, colors=pal_vec) %>%
            addLegend(pal = pal_vec, values = raster::values(v), title = "Surface temp") %>%
            # Add toggle layers control
            addLayersControl(overlayGroups = c("host", "vector"), options = layersControlOptions(collapsed = FALSE)) %>%
            hideGroup("vector")
    })
    
    # Add survey
    observe({
        leafletProxy("map", data = filteredData()) %>%
            clearShapes() %>%
            addCircles(radius = 2500, color = ~pal_survey(cbsd))
    })

}

shinyApp(ui, server)
