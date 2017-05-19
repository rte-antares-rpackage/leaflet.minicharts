.prepareArgs <- function(options, chartdata, popupArgs,
                         static = c("layerId", "lat", "lat0", "lat1", "lng", "lng0", "lng1")) {

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

  list(
    options = options,
    chartdata = chartdata,
    maxValues = maxValues,
    ncols = ncols,
    popupArgs = popupArgs,
    legendLab = I(legendLab)
  )
}
