# Copyright © 2016 RTE Réseau de transport d’électricité

#' Private function that prepare R arguments to be sent to javascript functions.
#'
#' @param required
#'   Named list of required parameters
#' @param optional
#'   Named list of optional parameters
#'
#' @return
#'   A data.frame where each column represent one parameter
#'
#' @noRd
#'
.makeOptions <- function(required, optional) {
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
