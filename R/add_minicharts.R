# Copyright © 2016 RTE Réseau de transport d’électricité

#' Add or update charts on a leaflet map
#'
#' these functions add or update minicharts in a leaflet map at given coordinates:
#' they can be bar charts, pie charts or polar charts where data is encoded
#' either by area or by radius.
#'
#' @param map A leaflet map object created with \code{\link[leaflet]{leaflet}}.
#' @param lng Longitude where to place the charts.
#' @param lat Lattitude where to place the charts.
#' @param data A numeric matrix with number of rows equal to the number of
#'   elements in \code{lng} or \code{lat} and number of column equal to the
#'   number of variables to represent. If parameter \code{time} is set, the
#'   number of rows must be equal to the length of \code{lng} times the number
#'   of unique time steps in the data.
#' @param time A vector with length equal to the number of rows in \code{data}
#'   and containing either numbers representing time indices or dates or
#'   datetimes. Each unique value must appear as many times as the others. This
#'   parameter can be used when one wants to represent the evolution of some
#'   variables on a map.
#' @param maxValues maximal absolute values of the variables to represent.
#'   It can be a vector with one value per column of \code{data} or a single
#'   value. Using a single value enforces charts to use a unique scale for all
#'   variables. If it is \code{NULL}, the maximum value of \code{data} is used.
#' @param type Type of chart. Possible values are \code{"bar"} for bar charts,
#'   \code{"pie"} for pie charts, \code{"polar-area"} and \code{"polar-radius"}
#'   for polar area charts where the values are represented respectively by the
#'   area or the radius of the slices. Finally it can be equal to \code{"auto"},
#'   the default. In this case, if there is only one variable to represent, the
#'   chart will be a single circle, else it is a barchart.
#' @param fillColor Used only if data contains only one column. It is the color
#'   used to fill the circles.
#' @param colorPalette Color palette to use when \code{data} contains more than
#'   one column.
#' @param width maximal width of the created elements.
#' @param height maximal height of the created elements.
#' @param opacity Opacity of the chart.
#' @param showLabels Should values be displayed above chart elements.
#' @param labelText character vector containing the text content of the charts.
#'   Used only if \code{data} contains only one column.
#' @param labelStyle Character string containing CSS properties to apply to the
#'   labels.
#' @param labelMinSize Minimal height of labels in pixels. When there is not
#'   enough space for labels, they are hidden.
#' @param labelMaxSize Maximal height of labels in pixels.
#' @param transitionTime Duration in milliseconds of the transitions when a
#'   property of a chart is updated.
#' @param popup Content of the popup bind to a given chart. This can be html
#'   text.
#' @param layerId An ID variable. It is mandatoy when one wants to update some
#'   chart with \code{updateMinicharts}.
#' @param legend If TRUE and if data has column names, then a legend is
#'   automatically added to the map.
#'
#' @return
#' The modified leaflet map object.
#'
#' @examples
#' require(leaflet)
#' mymap <- leaflet() %>% addTiles() %>% addMinicharts(0, 0, data = 1:3, layerId = "c1")
#'
#' mymap
#' mymap %>% updateMinicharts("c1", maxValues = 6)
#' mymap %>% updateMinicharts("c1", type="pie")
#'
#' @export
#'
addMinicharts <- function(map, lng, lat, data = 1, time = NULL, maxValues = NULL, type = "auto",
                          fillColor = "blue", colorPalette = d3.schemeCategory10,
                          width = 30, height = 30, opacity = 1, showLabels = FALSE,
                          labelText = NULL, labelMinSize = 8, labelMaxSize = 24,
                          labelStyle = NULL,
                          transitionTime = 750, popup = NULL, layerId = NULL,
                          legend = TRUE) {

  type <- match.arg(type, c("auto", "bar", "pie", "polar-area", "polar-radius"))

  # Data preparation

  # When adding only one minichart, data can be a vector or a data frame, so it
  # needs to be converted to a matrix with correct lines and columns
  if (max(length(lng), length(lat)) == 1 & is.null(time)) {
    data <- matrix(data, nrow = 1)
  } else {
    if (is.vector(data)) {
      data <- matrix(data, ncol = 1, nrow = max(length(lng), length(lat)))
    }
  }

  legendLab <- dimnames(data)[[2]]
  data <- unname(as.matrix(data))

  # If maxValues is not set explicitely, we use the maximal observed value
  if (is.null(maxValues)) maxValues <- max(abs(data))

  # If there is only one variable in data, we draw circles with different radius
  # else we draw bar charts by default.
  if (type == "auto") {
    type <- ifelse (ncol(data) == 1, "polar-area", "bar")
  }

  # Split data by timeId
  if (is.null(time)) {
    data <- list(data)
    time <- 1
  } else {
    ncols <- ncol(data)
    data <- split(data, time) %>%
      lapply(., matrix, ncol = ncols) %>%
      unname()
  }

  if (showLabels) {
    if (!is.null(labelText)) labels <- labelText
    else labels <- "auto"
  } else {
    labels <- "none"
  }

  options <- .prepareOptions(
    required = list(lng = lng, lat = lat),
    optional = list(type = type, width = width, height = height,
                    opacity = opacity, labels = labels,
                    labelMinSize = labelMinSize, labelMaxSize = labelMaxSize,
                    labelStyle = labelStyle,
                    transitionTime = transitionTime,
                    popup = popup, layerId = layerId, fillColor = fillColor)
  )

  # Add minichart to the map dependencies
  minichartDep <- htmltools::htmlDependency(
    "minichart",
    "0.2.2",
    src = system.file(package = "leaflet.minicharts"),
    script = c("leaflet.minichart.min.js", "minichart_bindings.js", "timeslider.js")
  )
  map$dependencies <- c(map$dependencies, list(minichartDep))

  map <- invokeMethod(map, data = leaflet::getMapData(map), "addMinicharts",
                      options, data, unname(maxValues), colorPalette,
                      sort(unique(time)))

  # Generate a legend
  if (legend && !is.null(legendLab)) {
    legendCol <- colorPalette[(seq_len(ncol(data))-1) %% ncol(data) + 1]
    map <- addLegend(map, labels = legendLab, colors = legendCol, opacity = 1)
  }

  map %>% expandLimits(lat, lng)
}

#' @export
#' @rdname addMinicharts
updateMinicharts <- function(map, layerId, data = NULL, time = NULL, maxValues = NULL, type = NULL,
                             fillColor = NULL, colorPalette = NULL,
                             width = NULL, height = NULL, opacity = NULL, showLabels = NULL,
                             labelText = NULL, labelMinSize = NULL,
                             labelMaxSize = NULL, labelStyle = NULL,
                             transitionTime = NULL, popup = NULL) {

  type <- match.arg(type, c("auto", "bar", "pie", "polar-area", "polar-radius"))

  # Data preparation
  if (!is.null(data)) {
    if (length(layerId) == 1 & is.null(time)) {
      data <- matrix(data, nrow = 1)
    } else {
      if (is.vector(data)) {
        data <- matrix(data, ncol = 1, nrow = length(layerId))
      }
    }

    data <- unname(as.matrix(data))

    if (type == "auto") {
      type <- ifelse (ncol(data) == 1, "polar-area", "bar")
    }

    # Split data by timeId
    if (is.null(time)) {
      data <- list(data)
    } else {
      ncols <- ncol(data)
      data <- split(data, time) %>%
        lapply(., matrix, ncol = ncols) %>%
        unname()
    }
  } else {
    type <- NULL
  }

  if (is.null(showLabels)) {
    labels <- NULL
  } else {
    if (showLabels) {
      if (!is.null(labelText)) labels <- labelText
      else labels <- "auto"
    } else {
      labels <- "none"
    }
  }

  options <- .prepareOptions(
    required = list(layerId = layerId),
    optional = list(type = type, width = width, height = height,
                    opacity = opacity, labels = labels,
                    labelMinSize = labelMinSize, labelMaxSize = labelMaxSize,
                    labelStyle = labelStyle,
                    labelText = labelText, transitionTime = transitionTime,
                    popup = popup, fillColor = fillColor)
  )

  map %>%
    invokeMethod(NULL, "updateMinicharts",
                 options, data, unname(maxValues), colorPalette)

}
