# User interface
library(shiny)
library(leaflet)

ui <- fluidPage(
  titlePanel("Demo of leaflet.minicharts"),
  p("This application uses the data.frame 'eco2mix', included in the 'leaflet.minicharts' packages.",
    "It contains the monthly electric production of french regions from 2013 to 2017."),

  sidebarLayout(

    sidebarPanel(
      selectInput("prods", "Select productions", choices = prodCols, multiple = TRUE),
      selectInput("type", "Chart type", choices = c("bar","pie", "polar-area", "polar-radius")),
      checkboxInput("labels", "Show values")
    ),

    mainPanel(
      leafletOutput("map")
    )

  )
)
