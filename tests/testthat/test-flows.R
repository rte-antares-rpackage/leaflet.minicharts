context("flows")

# Helper function
expect_invoke_js_method <- function(method, postProcess = I) {
  map <- leaflet::leaflet() %>%
    addFlows(0, 0, 1, 1, layerId = "a") %>%
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

    test_that("One can add, update, clear and remove flows", {
      expect_invoke_js_method("addFlows")
      expect_invoke_js_method("updateFlows", function(map) {
        updateFlows(map, layerId = "a", flow = 0.5)
      })
      expect_invoke_js_method("clearFlows", clearFlows)
      expect_invoke_js_method("removeFlows", function(map) {
        removeFlows(map, "a")
      })
    })

  }
)
