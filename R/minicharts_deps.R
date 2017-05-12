minichartDeps <- function() {
  minichartDep <- htmltools::htmlDependency(
    "minichart",
    "0.2.2",
    src = system.file(package = "leaflet.minicharts"),
    stylesheet = c("minicharts.css"),
    script = c("leaflet.minicharts.min.js")
  )

  fontAwesomeDep <- htmltools::htmlDependency(
    "font-awesome",
    "4.7.0",
    src = system.file("font-awesome-4.7.0", package = "leaflet.minicharts"),
    stylesheet = "css/font-awesome.min.css"
  )

  list(minichartDep, fontAwesomeDep)
}
