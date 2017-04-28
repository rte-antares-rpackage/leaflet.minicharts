# User interface
ui <- fluidPage(
  titlePanel("Demo of leaflet.minicharts"),

  sidebarLayout(

    sidebarPanel(
      selectInput("prods", "Select productions", choices = prodCols, multiple = TRUE)
    ),

    mainPanel(
      leafletOutput("map")
    )

  )
)
