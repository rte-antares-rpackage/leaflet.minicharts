#' Options for popup generation
#'
#' This function simply returns a list of options to control the generation of
#' popups.
#'
#' @param showTitle If \code{TRUE} layer id is displayed as title of
#'   popups.
#' @param showValues If \code{TRUE}, values are displayed in popups
#' @param labels Names of values. If \code{NULL}, column names of the data bound
#'   to a chart are used.
#' @param supValues A \code{data.frame} containing additional values to display
#'   in popups.
#' @param supLabels Names of the additional values.
#' @param html Character vector containing custom html code for popups. You can
#'   use this parameter when you are not happy with the default popups.
#' @param noPopup If \code{TRUE}, popups are not created.
#' @param digits Max number of decimal digits to display for numeric values. If
#'   \code{NULL}, all digits are displayed.
#'
#' @return List containing options for popup generation
#'
#' @export
popupArgs <- function(showTitle = TRUE, showValues = TRUE, labels = NULL,
                      supValues = NULL, supLabels = colnames(supValues),
                      html = NULL, noPopup = FALSE, digits = NULL) {
  if(!showTitle && !showValues & is.null(html) & is.null(supValues)) noPopup <- TRUE
  if (!is.null(html) | noPopup) supValues <- NULL
  as.list(environment())
}
