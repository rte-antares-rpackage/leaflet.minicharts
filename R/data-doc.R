#' Electric production, consumption and exchanges of France
#'
#' @description
#' \code{eco2mix} contains the electric production, consumption and exchanges
#' of France from january 2010 to february 2017 and of 12 french regions from
#' january 2013 to february 2017.
#'
#' In addition to the total production, the table contains one column for each
#' type of production. The table also contains the lattitude and longitude of
#' the center of the regions.
#'
#' \code{eco2mixBalance} is an extract of \code{eco2mix} that contains only
#' exchanges between France and neighbouring countries, in a convenient format
#' to represent flows on a map.
#'
#' @docType data
#' @author Francois Guillem \email{francois.guillem@rte-france.com}
#' @references \url{http://www.rte-france.com/fr/eco2mix/eco2mix}
#' @keywords datasets
"eco2mix"

#' @rdname eco2mix
"eco2mixBalance"


#' d3 color palette
#'
#' @description
#' A character vector containing ten colors. These colors are used as the default
#' color palette
#' @docType data
#' @author Francois Guillem \email{francois.guillem@rte-france.com}
#' @references \url{https://github.com/d3/d3-scale}
#' @keywords datasets
"d3.schemeCategory10"
