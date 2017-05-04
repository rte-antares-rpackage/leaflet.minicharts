#' Add or modify flows on a leaflet map
#'
#' These functions can be used to represent flows and their evolution on a map
#' created with \code{\link[leaflet]{leaflet}()}. Flows are simply represented
#' by a segment between two points with an arrow at its center that indicates the
#' direction of the flow.
#'
#' @param lng0 Longitude of the origin of the flow.
#' @param lat0 Lattitude of the origin of the flow.
#' @param lng1 Longitude of the destination of the flow.
#' @param lat1 Lattitude of the destination of the flow.
#' @param color Color of the flow.
#' @param flow Value of the flow between the origin and the destination. If
#'   argument \code{dir} is not set, negative values are interpreted as flows
#'   from destination to origin.
#' @param opacity Opacity of the flow.
#' @param dir Direction of the flow. 1 indicates that the flow goes from origin
#'   to destination and -1 indicates that it goes from destination to origin. If
#'   0, the arrow is not drawn. If \code{NULL}, then it is equal to the sign of
#'   \code{weight}.
#' @param maxFlow Maximal value a flow could take.
#' @param minThickness minimal thickness of the line that represents the flow.
#' @param maxThickness maximal thickness of the line that represents the flow.
#' @inheritParams addMinicharts
#'
#' @return
#' The modified leaflet map object.
#'
#' @export
addFlows <- function(map, lng0, lat0, lng1, lat1, color = "blue", flow = 1,
                     opacity = 1, dir = NULL, time = NULL, popup = NULL, layerId = NULL,
                     timeFormat = NULL, initialTime = NULL, maxFlow = max(abs(flow)),
                     minThickness = 1, maxThickness = 20) {
  if (is.null(time)) time <- 1
  if (is.null(layerId)) layerId <- sprintf("Flow (%s,%s) -> (%s,%s)", lng0, lat0, lng1, lat1)

  weight <- minThickness + flow / maxFlow * (maxThickness - minThickness)

  if (is.null(dir)) dir <- sign(weight)
  weight <- pmax(minThickness, abs(weight))

  options <- .makeOptions(
    required = list(lng0 = lng0, lat0 = lat0, lng1 = lng1, lat1 = lat1, layerId = layerId, time = time),
    optional = list(dir = dir, color = color, weight = weight,
                    opacity = opacity, popup = popup)
  )

  args <- .prepareArgs(options, NULL)

  timeLabels <- sort(unique(time))
  if (!is.null(timeFormat)) {
    timeLabels <- format(timeLabels, format = timeFormat)
    if (!is.null(initialTime)) initialTime <- format(initialTime, format = timeFormat)
  }

  # Add minichart and font-awesome to the map dependencies
  map$dependencies <- c(map$dependencies, minichartDeps())

  invokeMethod(map, data = leaflet::getMapData(map), "addFlows", args$options,
               timeLabels, initialTime) %>%
    expandLimits(c(lat0, lat1), c(lng0, lng1))
}

#' @rdname addFlows
#' @export
updateFlows <- function(map, layerId, color = NULL, flow = NULL, opacity = NULL,
                        dir = NULL, time = NULL, popup = NULL,
                        timeFormat = NULL, initialTime = NULL, maxFlow = NULL,
                        minThickness = 1, maxThickness = 20) {
  if (is.null(time)) time <- 1
  if (!is.null(flow)) {
    if (is.null(maxFlow)) maxFlow = max(flow)
    weight <- minThickness + flow / maxFlow * (maxThickness - minThickness)

    if (is.null(dir)) dir <- sign(weight)
    weight <- pmax(minThickness, abs(weight))
  }

  options <- .makeOptions(
    required = list(layerId = layerId, time = time),
    optional = list(dir = dir, color = color, weight = weight,
                    opacity = opacity, popup = popup)
  )

  args <- .prepareArgs(options, NULL)

  if(is.null(weight)) {
    timeLabels <- NULL
  } else {
    timeLabels <- sort(unique(time))
    if (!is.null(timeFormat)) {
      timeLabels <- format(timeLabels, format = timeFormat)
      if (!is.null(initialTime)) initialTime <- format(initialTime, format = timeFormat)
    }
  }

  invokeMethod(map, data = leaflet::getMapData(map), "updateFlows", args$options,
               I(timeLabels), initialTime)
}

#' @rdname addFlows
#' @export
removeFlows <- function(map, layerId) {
  invokeMethod(map, leaflet::getMapData(map), "removeFlows", layerId)
}

#' @rdname addFlows
#' @export
clearFlows <- function(map) {
  invokeMethod(map, leaflet::getMapData(map), "clearFlows") %>%
    leaflet::removeControl("minichartsLegend")
}
