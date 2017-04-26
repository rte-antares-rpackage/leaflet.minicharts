.prepareArgs <- function(options, chartdata) {

  correctOrder <- order(options$time, options$layerId)

  if (is.null(chartdata)) {
    legendLab <- NULL
    maxValues <- NULL
    ncols <- NULL
  } else {
    # When adding only one minichart, chartdata can be a vector or a data frame, so it
    # needs to be converted to a matrix with correct lines and columns
    if (nrow(options) == 1) {
      chartdata <- matrix(chartdata, nrow = 1)
    } else {
      if (is.vector(chartdata)) {
        chartdata <- matrix(chartdata, ncol = 1, nrow = nrow(options))
      }
    }

    # Save column names for legend and transform data in a matrix without names
    legendLab <- dimnames(chartdata)[[2]]
    chartdata <- unname(as.matrix(chartdata))

    # Save additional information about data before splitting it
    maxValues <- max(abs(chartdata))
    ncols <- ncol(chartdata)

    # sort data and split it by time
    chartdata <- chartdata[correctOrder, ] %>%
      split(options$time[correctOrder]) %>%
      lapply(., matrix, ncol = ncols) %>%
      unname()
  }

  options <- options[correctOrder, ]
  options <- options[!duplicated(options$layerId),]

  # If there is only one variable in chartdata, we draw circles with different radius
  # else we draw bar charts by default.
  if ("type" %in% names(options) && options$type[1] == "auto") {
    options$type <- ifelse (!is.null(ncols) && ncols == 1, "polar-area", "bar")
  }

  list(
    options = options,
    chartdata = chartdata,
    legendLab = legendLab,
    maxValues = maxValues,
    ncols = ncols
  )
}
