#' Synchronize multiple maps
#'
#' @description
#' This function can be used when multiple leaflet maps are displayed on the
#' same view (for instance in a shiny application or a Rmarkdown document) and
#' one wants to synchronize their center, zoom and time.
#'
#' \code{syncWith()} can also be used with basic leaflet maps to synchronize
#' only their zoom and center.
#'
#' @param groupname Character string. All maps that use the same group name will
#'   be synchronized.
#' @inheritParams addMinicharts
#'
#' @return The modified leaflet map object.
#'
#' @examples
#' if (require(manipulateWidget) & require(leaflet)) {
#'
#'   # Synchronize zoom and center of basic maps.
#'   basicMap1 <- leaflet() %>% addTiles() %>% syncWith("basicmaps")
#'   basicMap2 <- leaflet() %>% addTiles() %>% syncWith("basicmaps")
#'   combineWidgets(basicMap1, basicMap2)
#'
#'   # Synchronize time step of two maps that represent the evolution of some
#'   # variable.
#'   map1 <- leaflet() %>% addTiles() %>%
#'     addMinicharts(0, 40, chartdata = 1:10, time = 1:10) %>%
#'     syncWith("maps")
#'   map2 <- leaflet() %>% addTiles() %>%
#'     addMinicharts(0, 40, chartdata = 10:1, time = 1:10) %>%
#'     syncWith("maps")
#'   combineWidgets(map1, map2)
#'
#' }
#'
#' @export
syncWith <- function(map, groupname) {
  invokeMethod(map, data = leaflet::getMapData(map), "syncWith", groupname)
}
