context(".prepareJSArgs")

describe(".prepareJSArgs", {

  # Prepare some fake data
  layerIds <- c("a", "b")
  nLayers <- length(layerIds)
  nTimeIds <- 5

  mydata <- data.frame(
    a = rnorm(nLayers * nTimeIds),
    b = rnorm(nLayers * nTimeIds)
  )

  myOptions <- .preprocessArgs(
    list(
      lng = rep(1:nLayers, each = nTimeIds),
      lat = rep(1:nLayers, each = nTimeIds),
      layerId = rep(layerIds, each = nTimeIds),
      time = rep(1:nTimeIds, each = nLayers)
    ),
    list(
      width = 60,
      height = seq_len(nLayers * nTimeIds)
    )
  )

  jsArgs <- .prepareJSArgs(myOptions, mydata, NULL)

  it("returns an object with the correct structure", {
    elements <- c("options", "chartdata", "maxValues", "ncols", "legendLab")
    expect_true(all(elements %in% names(jsArgs)))

    it("splits options by layer", {
      expect_is(jsArgs$options, "list")
      expect_equal(length(jsArgs$options), nLayers)

      for (i in seq_len(nLayers)) {
        expect_equal(names(jsArgs$options[[i]]), c("dyn", "static", "timeSteps"))

        expect_is(jsArgs$options[[i]]$dyn, "data.frame")
        expect_equal(names(jsArgs$options[[i]]$dyn), "height")
        expect_equal(nrow(jsArgs$options[[i]]$dyn), nTimeIds)

        expect_is(jsArgs$options[[i]]$static, "list")
        expect_true(all(c("lng", "lat", "layerId", "width") %in% names(jsArgs$options[[i]]$static)))

        expect_equal(jsArgs$options[[i]]$timeSteps, nTimeIds)
      }
    })


    it ("splits data by layer", {

    })
  })


})
