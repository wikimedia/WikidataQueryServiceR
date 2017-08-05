context("Querying")

query <- "SELECT DISTINCT
  ?softwareVersion ?publicationDate
WHERE {
  BIND(wd:Q206904 AS ?R)
  ?R p:P348 [
    ps:P348 ?softwareVersion;
    pq:P577 ?publicationDate
  ] .
}"

suppressMessages({
  simple_results <- query_wikidata(query, format = "simple")
  smart_results <- query_wikidata(query, format = "smart")
})

test_that("data", {
  expect_s3_class(simple_results, "data.frame")
  expect_s3_class(smart_results, "data.frame")
  expect_equal(names(simple_results), c("softwareVersion", "publicationDate"))
  expect_equal(names(smart_results), c("softwareVersion", "publicationDate"))
})

test_that("date formatting", {
  expect_s3_class(smart_results$publicationDate, "POSIXct")
})

test_that("simple ~= smart", {
  expect_equal(nrow(simple_results), nrow(smart_results))
})
