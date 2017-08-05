if (requireNamespace("lintr", quietly = TRUE)) {
  context("Lints")
  test_that("package style", {
    lintr::expect_lint_free()
  })
}
