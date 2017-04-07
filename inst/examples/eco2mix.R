prod2016 <- eco2mix %>%
  mutate(
    renewable = bioenergy + solar + wind + hydraulic,
    non_renewable = total - bioenergy - solar - wind - hydraulic
  ) %>%
  filter(grepl("2016", month) & area != "France") %>%
  select(-month) %>%
  group_by(area, lat, lng) %>%
  summarise_all(sum) %>%
  ungroup()

prods <- prod2016 %>% select(thermal, bioenergy, solar, wind, hydraulic)

renewable <- prod2016 %>%
  select(hydraulic, solar, wind)

maxValues <- renewable %>%
  summarise_all(max) %>%
  unlist()


tilesURL <- "http://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}"

leaflet() %>%
  addTiles(tilesURL) %>%
  addMinicharts(
    prod2016$lng, prod2016$lat,
    type = "pie",
    data = prod2016[, c("renewable", "non_renewable")],
    width = 60 * sqrt(prod2016$total) / sqrt(max(prod2016$total))
  )

leaflet() %>%
  addTiles(tilesURL) %>%
  addMinicharts(
    prod2016$lng, prod2016$lat,
    data = prod2016[, c("renewable", "non_renewable")],
    width = 60 * sqrt(prod2016$total) / sqrt(max(prod2016$total))
  )


