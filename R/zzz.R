# Copyright © 2016 RTE Réseau de transport d’électricité
#' @importFrom leaflet expandLimits invokeMethod %>% addLegend JS
NULL

globalVariables(c('d3.schemeCategory10', "."))

.onLoad <- function(libname, pkgname) {
  utils::data("d3.schemeCategory10", package=pkgname, envir=parent.env(environment()))
}
