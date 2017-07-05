context("minichart")

# Helper function
expect_invoke_js_method <- function(method, postProcess = I) {
  map <- leaflet::leaflet() %>%
    addMinicharts(0, 0, 1:3, layerId = "a") %>%
    postProcess()

  expect_true(all(method %in% map$jsmethods))
}

with_mock(
  `leaflet::invokeMethod` = function(map, data, method, ...) {
    map$jsargs = list(...)
    map$jsmethods <- c(map$jsmethods, method)
    map
  },
  {

    test_that("One can add, update, clear and remove minicharts", {
      expect_invoke_js_method("addMinicharts")
      expect_invoke_js_method("updateMinicharts", function(map) {
        updateMinicharts(map, layerId = "a", chartdata = 1:4)
      })
      expect_invoke_js_method("clearMinicharts", clearMinicharts)
      expect_invoke_js_method("removeMinicharts", function(map) {
        removeMinicharts(map, "a")
      })
    })

  }
)
