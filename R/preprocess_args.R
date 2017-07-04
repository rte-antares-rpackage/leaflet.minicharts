# Copyright © 2016 RTE Réseau de transport d’électricité

#' Private function that prepare arguments for other functions. It transforms
#' them in a table with one column per argument. In order to improve memory
#' management, optional arguments with a single value are not added to the table
#' but there value is stored in a specific list.
#'
#' @param required
#'   Named list of required parameters
#' @param optional
#'   Named list of optional parameters
#'
#' @return
#'   A list with two elements:
#'   - options: data.frame with required args and variing optional args
#'   - staticOptions: a list with single value args.
#'
#' @noRd
#'
.preprocessArgs <- function(required, optional) {
  options <- do.call(data.frame, required)
  staticOptions <- list()
  for (o in names(optional)) {
    if (!is.null(optional[[o]])) {
      if (length(optional[[o]]) == 1) {
        staticOptions[[o]] <- optional[[o]]
      } else {
        options[[o]] <- optional[[o]]
      }
    }
  }
  list(
    options = options,
    staticOptions = staticOptions
  )
}
