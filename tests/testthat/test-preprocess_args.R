context(".preprocessArgs")

describe(".preprocessArgs", {
  it ("creates a data.frame with one column per argument", {
    opts <- .preprocessArgs(list(a = 1:3, b = 4:6), list(c = 7:9, d = 10:12))
    expect_is(opts$options, "data.frame")
    expect_equal(dim(opts$options), c(3, 4))
    expect_equal(names(opts$options), c("a", "b", "c", "d"))
  })

  it ("separates static optional arguments", {
    opts <- .preprocessArgs(list(a = 1:3, b = 4:6), list(c = 7:9, d = 10))
    expect_is(opts$options, "data.frame")
    expect_equal(dim(opts$options), c(3, 3))
    expect_equal(names(opts$options), c("a", "b", "c"))
    expect_is(opts$staticOptions, "list")
    expect_equal(names(opts$staticOptions), "d")
  })

  it ("does not separate static required arguments", {
    opts <- .preprocessArgs(list(a = 1:3, b = 4), list(c = 7:9, d = 10:12))
    expect_is(opts$options, "data.frame")
    expect_equal(dim(opts$options), c(3, 4))
    expect_equal(names(opts$options), c("a", "b", "c", "d"))
    expect_equal(length(opts$staticOptions), 0)
  })

  it ("does not accept NULL required arguments", {
    expect_error(.preprocessArgs(list(a = 1:3, b = NULL), list(c = 7:9, d = 10:12)))
  })

  it ("accepts NULL optional required", {
    opts <- .preprocessArgs(list(a = 1:3, b = 4:6), list(c = 7:9, d = NULL))
    expect_is(opts$options, "data.frame")
    expect_equal(dim(opts$options), c(3, 3))
    expect_equal(names(opts$options), c("a", "b", "c"))
    expect_equal(length(opts$staticOptions), 0)
  })

})
