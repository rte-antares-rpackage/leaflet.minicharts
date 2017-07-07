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
    map$jsargs <- list(...)
    map$jsmethods <- c(map$jsmethods, method)
    map
  },
  `leaflet::addLegend` = function(map, ...) {
    map$legendArgs <- list(...)
    map
  },
  `leaflet::removeControl` = function(map, id) {
    map$controlRemoved <- id
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

    describe("addMinicharts", {
      it("correctly manages the 'labels' argument", {
        # No labels
        map <- leaflet::leaflet() %>% addMinicharts(0, 0, 1:3, layerId = "a")
        expect_equal(map$jsargs[[1]][[1]]$static$labels, "none")
        # Auto labels
        map <- leaflet::leaflet() %>%
          addMinicharts(0, 0, 1:3, layerId = "a", showLabels = TRUE)
        expect_equal(map$jsargs[[1]][[1]]$static$labels, "auto")
        # Custom labels
        map <- leaflet::leaflet() %>%
          addMinicharts(0, 0, 1, layerId = "a", showLabels = TRUE,
                        labelText = "test")
        expect_equal(map$jsargs[[1]][[1]]$static$labels, "test")
      })

      it("adds a legend when chartdata has multiple named columns", {
        map <- leaflet::leaflet() %>%
          addMinicharts(0, 0, data.frame(a = 1, b = 2), layerId = "a")
        expect_false(is.null(map$legendArgs))
        expect_equal(map$legendArgs$labels, I(c("a", "b")))
        # No names, no legend
        map <- leaflet::leaflet() %>% addMinicharts(0, 0, 1:3, layerId = "a")
        expect_null(map$legendArgs)
        # One column, no legend
        map <- leaflet::leaflet() %>%
          addMinicharts(0, 0, data.frame(a = 1), layerId = "a")
        expect_null(map$legendArgs)
        # Argument legend is FALSE
        map <- leaflet::leaflet() %>%
          addMinicharts(0, 0, data.frame(a = 1, b = 2), layerId = "a",
                        legend = FALSE)
        expect_null(map$legendArgs)
      })
    })

    describe("updateMinicharts", {
      basemap <- leaflet::leaflet() %>% addMinicharts(0, 0, 1)

      it("correctly manages the 'labels' argument", {
        # No labels
        map <- basemap %>% updateMinicharts("a", showLabels = FALSE)
        expect_equal(map$jsargs[[1]][[1]]$static$labels, "none")
        # Auto labels
        map <- basemap %>% updateMinicharts("a", showLabels = TRUE)
        expect_equal(map$jsargs[[1]][[1]]$static$labels, "auto")
        # Custom labels
        map <- basemap %>%
          updateMinicharts("a", showLabels = TRUE, labelText = "test")
        expect_equal(map$jsargs[[1]][[1]]$static$labels, "test")
      })

      it ("does not update labels by default", {
        map <- basemap %>% updateMinicharts("a")
        expect_null(map$jsargs[[1]][[1]]$static$labels)
      })

      it ("updates time slider only when data is updated", {
        map <- basemap %>% updateMinicharts("a")
        expect_null(map$jsargs[[5]])

        map <- basemap %>% updateMinicharts("a", chartdata = 2)
        expect_false(is.null(map$jsargs[[5]]))
      })

      it ("updates legend only when data is updated", {
        baseMap <- leaflet::leaflet() %>% addMinicharts(0, 0, 1, layerId = "a")

        map <- baseMap %>% updateMinicharts("a", data.frame(a = 1, b = 2))
        expect_false(is.null(map$legendArgs))
        expect_equal(map$legendArgs$labels, I(c("a", "b")))
        # No names, no legend
        map <- baseMap %>% updateMinicharts("a", 1:3)
        expect_null(map$legendArgs)
        expect_equal(map$controlRemoved, "minichartsLegend")
        # One column, no legend
        map <- baseMap %>% updateMinicharts("a", data.frame(a = 1))
        expect_null(map$legendArgs)
        expect_equal(map$controlRemoved, "minichartsLegend")
        # Argument legend is FALSE
        map <- baseMap %>% updateMinicharts("a", data.frame(a = 1, b = 2), legend = FALSE)
        expect_null(map$legendArgs)
        expect_equal(map$controlRemoved, "minichartsLegend")

        # data is not updated
        map <- baseMap %>% updateMinicharts("a")
        expect_null(map$legendArgs)
        expect_null(map$controlRemoved)
      })

    })

  }
)
