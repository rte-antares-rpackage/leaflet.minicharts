library(dplyr)
library(shiny)
library(leaflet)
library(leaflet.minicharts)

data("eco2mix")
load("regions.rda")

# Remove data for the whole country
prodRegions <- eco2mix %>% filter(area != "France")

# Production columns
prodCols <- names(prodRegions)[6:13]

# Create base map
tilesURL <- "http://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}"

basemap <- leaflet(width = "100%", height = "400px") %>%
  addTiles(tilesURL) %>%
  addPolylines(data = regions, weight = 1, color = "brown")
