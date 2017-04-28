#' @title Scrape an example SPARQL query from Wikidata
#' @description Scrapes [SPARQL query service examples page](https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service/queries/examples)
#'   for specified example(s). Requires rvest and urltools packages.
#' @details If you are planning on scraping multiple examples, please provide
#'   all the names as a single vector.
#' @param example_name The names of the examples as they appear on
#'   [this page](https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service/queries/examples)
#' @param ... Additional `httr` configurations passed to `rvest`
#' @return The SPARQL query as a character vector.
#' @examples
#' \dontrun{
#' sparql_query <- scrape_example(c("Cats", "Horses"))
#' query_wikidata(sparql_query)
#' # returns a named list with two data frames
#' # one called "Cats" and one called "Horses"
#'
#' sparql_query <- scrape_example("Largest cities with female mayor")
#' cat(sparql_query)
#' query_wikidata(sparql_query)
#' }
#' @export
scrape_example <- function(example_name, ...) {
  if (requireNamespace("rvest", quietly = TRUE) && requireNamespace("urltools", quietly = TRUE)) {
    html <- rvest::html_session("https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service/queries/examples",
                                httr::user_agent("https://github.com/bearloga/WikidataQueryServiceR"), ...)
    return(vapply(example_name, function(example_name) {
      try_it <- rvest::html_node(html, xpath = paste0("//span[contains(text(), '", example_name, "') and @class='mw-headline']/following::p[descendant::a]/a"))
      href <- rvest::html_attr(try_it, "href")
      if (is.na(href)) {
        warning("could not find a query for example \"", example_name, "\"")
        return(invisible(NULL))
      }
      sparql_query <- urltools::url_decode(sub("//query.wikidata.org/#", "", href, fixed = TRUE))
      return(paste0(paste("#", example_name), "\n", sparql_query, collapse = "\n"))
    }, ""))
  } else {
    stop("\"rvest\" and \"urltools\" packages required for web-scraping")
  }
}
