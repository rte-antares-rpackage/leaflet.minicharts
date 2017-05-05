# server function
function(input, output, session) {
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
        time = prodRegions$month,
        type = ifelse(length(input$prods) < 2, "polar-area", input$type),
        showLabels = input$labels
      )
  })
}
