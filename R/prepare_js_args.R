#' Prepare arguments before sending them to the javascript program.
#'
#' Globally the function reorder data by layerId and time and then it split it
#' by layerId. It also compute some useful values like labels for legend,
#' domain of data, number of data columns.
#'
#' @param options Object created with .preprocessArgs()
#' @param chartdata Data to represent with minicharts
#' @param popupArgs object created with function popupArgs()
#' @param onChange see addMinicharts()
#'
#' @return
#' A list with the following elements:
#' - options:   data.frame of graphical options, split by layerId
#' - chartdata: numeric matrix split by layerId
#' - maxValues: maximal value observed in chartdata (NULL if chartdata is NULL)
#' - ncols: number of columns in chartdata
#' - popupArgs: List containing additional data to display in popups (or the
#'      popup HTML) split by layerId
#' - legendLab: Labels to use in legends
#' - onChange:  Javascript function that will be executed when charts are
#'      updated
#'
#' @noRd
#'
.prepareJSArgs <- function(options, chartdata = NULL, popupArgs = NULL,
                           onChange = NULL) {

  static <- c("layerId", "lat", "lat0", "lat1", "lng", "lng0", "lng1")

  staticOptions <- options$staticOptions
  options <- options$options

  correctOrder <- order(options$layerId, options$time)

  options <- options[correctOrder, ]

  if (is.null(chartdata)) {
    legendLab <- NULL
    maxValues <- NULL
    ncols <- 0
  } else {
    # When adding only one minichart, chartdata can be a vector or a data frame, so it
    # needs to be converted to a matrix with correct lines and columns
    if (nrow(options) == 1 && is.vector(chartdata)) {
      chartdata <- matrix(chartdata, nrow = 1)
    } else {
      if (is.vector(chartdata)) {
        chartdata <- matrix(chartdata, ncol = 1, nrow = nrow(options))
      }
    }

    # Save column names for legend and transform data in a matrix without names
    if (!is.null(popupArgs)) {
      if (is.null(popupArgs$labels)) popupArgs$labels <- colnames(chartdata)
      legendLab <- popupArgs$labels
    } else {
      legendLab <- colnames(chartdata)
    }
    chartdata <- unname(as.matrix(chartdata))

    # Save additional information about data before splitting it
    maxValues <- max(abs(chartdata))
    ncols <- ncol(chartdata)

    # sort data and split it by layer
    chartdata <- chartdata[correctOrder, ] %>%
      split(options$layerId, drop = TRUE) %>%
      lapply(matrix, ncol = ncols) %>%
      unname()
  }

  # Popup additional data
  if (!is.null(popupArgs$supValues)) {
    if (is.null(popupArgs$supLabels)) popupArgs$supLabels <- colnames(popupArgs$supValues)

    if (is.null(popupArgs$supLabels) && !is.null(popupArgs$labels)) {
      popupArgs$supLabels <- rep("", ncol(popupArgs$supValues))
    } else if (is.null(popupArgs$labels) && !is.null(popupArgs$supLabels)) {
      popupArgs$labels <-rep("", ncols)
    }

    popupArgs$supValues <- popupArgs$supValues[correctOrder, ] %>%
      as.matrix() %>%
      split(options$layerId, drop = TRUE) %>%
      lapply(matrix, ncol = ncol(popupArgs$supValues)) %>%
      unname()
  }

  # Popup html
  if (!is.null(popupArgs$html)) {
    popupArgs$html <- popupArgs$html[correctOrder] %>%
      split(options$layerId, drop = TRUE) %>%
      lapply(I) %>%
      unname()
  }


  # If there is only one variable in chartdata, we draw circles with different radius
  # else we draw bar charts by default.
  if ("type" %in% names(staticOptions) && staticOptions$type == "auto") {
    staticOptions$type <- ifelse (!is.null(ncols) && ncols == 1, "polar-area", "bar")
  }

  # Ensure layerId is a character vector
  if ("layerId" %in% names(options)) options$layerId <- as.character(options$layerId)

  # Finally split options by layer
  options <- split(options, options$layerId, drop = TRUE) %>%
    unname() %>%
    lapply(function(df) {
      df$time <- NULL
      res <- list(dyn = df, static = list(), timeSteps = nrow(df))
      # Add common static options
      for (var in names(staticOptions)) {
        res$static[[var]] <- staticOptions[[var]]
      }
      # Add individual static options
      for (var in static) {
        if (var %in% names(df)) {
          res$dyn[[var]] <- NULL
          res$static[[var]] <- df[[var]][1]
        }
      }
      res
    })

  # Ensure labels will always be translated as arrays in JSON
  if(!is.null(popupArgs)) {
    popupArgs$labels <- I(popupArgs$labels)
    popupArgs$supLabels <- I(popupArgs$supLabels)
  }

  # Prepare onChange argument
  if (!is.null(onChange)) {
    onChange <- sprintf("(function(opts, popup, d3){%s})", onChange)
    onChange <- JS(onChange)
  }

  list(
    options = options,
    chartdata = chartdata,
    maxValues = maxValues,
    ncols = ncols,
    popupArgs = popupArgs,
    legendLab = I(legendLab),
    onChange = onChange
  )
}
