library(shiny)
library(leaflet)
library(leaflet.minicharts)

data("regions")
data("eco2mix")

# Remove data for the whole country
prodRegions <- eco2mix %>% filter(area != "France")

# Production columns
prodCols <- names(prodRegions)[6:13]

# Create base map
tilesURL <- "http://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}"

basemap <- leaflet(width = "100%", height = "400px") %>%
  addTiles(tilesURL) %>%
  addPolylines(data = regions, color = "brown", weight = 1, fillOpacity = 0)

# server function
server <- function(input, output, session) {
  # Initialize map
  output$map <- renderLeaflet({
    basemap %>%
      addMinicharts(
        prodRegions$lng, prodRegions$lat,
        layerId = prodRegions$area,
        width = 45, height = 45
      )
  })

  # Update charts each time input value changes
  observe({
    if (length(input$prods) == 0) {
      data <- 1
    } else {
      data <- prodRegions[, input$prods]
    }
    maxValue <- max(as.matrix(data))

    leafletProxy("map", session) %>%
      updateMinicharts(
        prodRegions$area,
        chartdata = data,
        maxValues = maxValue,
        time = prodRegions$month
      )
  })
}
