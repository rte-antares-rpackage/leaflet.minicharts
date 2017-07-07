context(".prepareJSArgs")

describe(".prepareJSArgs", {

  # Prepare some fake data
  nTimeIds <- 5
  layerIds <- c("a", "b")
  nLayers <- length(layerIds)

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

  jsArgs <- .prepareJSArgs(myOptions, mydata)

  # Helper functions
  expect_split_by_layer <- function(x, checkElement) {
    expect_is(x, "list")
    expect_equal(length(x), nLayers)
    for (el in x) {
      checkElement(el)
    }
  }

  it("returns an object with the correct structure", {
    elements <- c("options", "chartdata", "maxValues", "ncols", "legendLab",
                  "onChange", "timeLabels", "initialTime")
    expect_true(all(elements %in% names(jsArgs)))
    expect_is(jsArgs$legendLab, "AsIs")
    expect_equal(jsArgs$legendLab, I(colnames(mydata)))
    expect_equal(jsArgs$maxValues, max(abs(mydata)))
    expect_equal(jsArgs$ncols, ncol(mydata))
    expect_is(jsArgs$timeLabels, "AsIs")

    expect_split_by_layer(jsArgs$options, function(el) {
      expect_is(el$dyn, "data.frame")
      expect_equal(names(el$dyn), "height")
      expect_equal(nrow(el$dyn), nTimeIds)

      expect_is(el$static, "list")
      expect_true(all(c("lng", "lat", "layerId", "width") %in% names(el$static)))

      expect_equal(el$timeSteps, nTimeIds)
    })

    expect_split_by_layer(jsArgs$chartdata, function(el) {
      expect_is(el, "matrix")
      expect_equal(mode(el), "numeric")
      expect_equal(dim(el), c(nTimeIds, ncol(mydata)))
    })
  })

  it ("handles case when chartdata is a vector", {
    it ("single timeId and layer", {
      singleOption <- list(options = myOptions$options[1,])
      myData <- 1:3
      jsArgs <- .prepareJSArgs(singleOption, myData)
      expect_equal(length(jsArgs$chartdata), 1)
      expect_equal(dim(jsArgs$chartdata[[1]]), c(1, length(myData)))
    })

    it ("single column", {
      myData <- 1:nrow(myOptions$options)
      jsArgs <- .prepareJSArgs(myOptions, myData)
      expect_split_by_layer(jsArgs$chartdata, function(el) {
        expect_is(el, "matrix")
        expect_equal(mode(el), "numeric")
        expect_equal(dim(el), c(nTimeIds, 1))
      })
    })

    it ("single value", {
      myData <- 1
      jsArgs <- .prepareJSArgs(myOptions, myData)
      expect_split_by_layer(jsArgs$chartdata, function(el) {
        expect_is(el, "matrix")
        expect_equal(mode(el), "numeric")
        expect_equal(dim(el), c(nTimeIds, 1))
        expect_true(all(el == myData))
      })
    })
  })

  it ("uses default values when chartdata is NULL", {
    expect_silent(jsArgs <- .prepareJSArgs(myOptions, NULL))
    expect_equal(jsArgs$legendLab, I(list()))
    expect_equal(jsArgs$maxValues, NULL)
    expect_equal(jsArgs$ncols, 0)
  })

  it ("chooses correct type when type = 'auto'", {

    it ("multiple columns", {
      myOptions$staticOptions$type <- "auto"
      jsArgs <- .prepareJSArgs(myOptions, mydata)
      expect_split_by_layer(jsArgs$options, function(el) {
        expect_equal(el$static$type, "bar")
      })
    })

    it ("single column", {
      myOptions$staticOptions$type <- "auto"
      jsArgs <- .prepareJSArgs(myOptions, mydata[, "a", drop = FALSE])
      expect_split_by_layer(jsArgs$options, function(el) {
        expect_equal(el$static$type, "polar-area")
      })
    })


  })

  it ("transforms 'onChange' in a javascript function", {
    jsArgs <- .prepareJSArgs(myOptions, onChange = "console.log('ok')")
    expect_is(jsArgs$onChange, "JS_EVAL")
    expect_true(grepl("^\\(function\\(.+\\) ?\\{.+\\}\\)", jsArgs$onChange))
  })

  it ("supports custom popups", {

    it ("custom html", {
      html <- rnorm(nLayers * nTimeIds)

      jsArgs <- .prepareJSArgs(myOptions, mydata, popupArgs(html = html))
      expect_split_by_layer(jsArgs$popupArgs$html, function(el) {
        expect_is(el, "AsIs")
        expect_equal(mode(el), "character")
        expect_equal(length(el), nTimeIds)
      })
    })

    it ("custom labels", {
      jsArgs <- .prepareJSArgs(myOptions, mydata, popupArgs(labels = c("c", "d")))
      expect_equal(jsArgs$legendLab, I(c("c", "d")))
    })

    it ("additional data", {
      popupData <- data.frame(
        c = rnorm(nLayers * nTimeIds),
        d = rnorm(nLayers * nTimeIds)
      )

      jsArgs <- .prepareJSArgs(myOptions, mydata,
                               popupArgs(supValues = popupData))

      expect_split_by_layer(jsArgs$popupArgs$supValues, function(el) {
        expect_is(el, "matrix")
        expect_equal(mode(el), "numeric")
        expect_equal(dim(el), c(nTimeIds, ncol(mydata)))
      })
      expect_is(jsArgs$popupArgs$supLabels, "AsIs")
      expect_equal(jsArgs$popupArgs$supLabels, I(names(popupData)))
    })
  })

  it ("fills missing labels", {
    popupData <- data.frame(
      c = rnorm(nLayers * nTimeIds),
      d = rnorm(nLayers * nTimeIds)
    )

    jsArgs <- .prepareJSArgs(myOptions, mydata,
                             popupArgs(supValues = unname(popupData)))
    expect_equal(jsArgs$popupArgs$labels, I(names(mydata)))
    expect_equal(jsArgs$popupArgs$supLabels, I(c("", "")))

    jsArgs <- .prepareJSArgs(myOptions, unname(mydata),
                             popupArgs(supValues = popupData))
    expect_equal(jsArgs$popupArgs$labels, I(c("", "")))
    expect_equal(jsArgs$popupArgs$supLabels, I(names(popupData)))
  })

  it ("can use custom format for time labels", {
    myOptions$options$time <- Sys.Date() + myOptions$options$time
    format <- "%m - %d"
    expectedLabels <- format(unique(myOptions$options$time), format = format)

    jsArgs <- .prepareJSArgs(myOptions, mydata, timeFormat = format,
                             initialTime = min(myOptions$options$time))
    expect_equal(jsArgs$timeLabels, I(expectedLabels))
    expect_equal(jsArgs$initialTime, expectedLabels[1])
  })

  it ("returns timeLabels and initialTimes in character format", {
    jsArgs <- .prepareJSArgs(myOptions, mydata,
                             initialTime = min(myOptions$options$time))
    expect_equal(mode(jsArgs$timeLabels), "character")
    expect_is(jsArgs$initialTime, "character")
  })
})
