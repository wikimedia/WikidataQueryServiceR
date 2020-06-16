#' @title Send one or more SPARQL queries to WDQS
#' @description Makes a POST request to Wikidata Query Service SPARQL endpoint.
#' @param sparql_query SPARQL query (can be a vector of queries)
#' @param format "simple" uses CSV and returns pure character data frame, while
#'   "smart" fetches JSON-formatted data and returns a data frame with datetime
#'   columns converted to `POSIXct`
#' @return A tibble data frame
#' @examples
#' sparql_query <- "SELECT
#'   ?softwareVersion ?publicationDate
#' WHERE {
#'   BIND(wd:Q206904 AS ?R)
#'   ?R p:P348 [
#'     ps:P348 ?softwareVersion;
#'     pq:P577 ?publicationDate
#'   ] .
#' }"
#' query_wikidata(sparql_query)
#'
#' \dontrun{
#' query_wikidata(sparql_query, format = "smart")
#' }
#' @section Query limits:
#' There is a hard query deadline configured which is set to 60 seconds. There
#' are also following limits:
#' - One client (user agent + IP) is allowed 60 seconds of processing time each
#'   60 seconds
#' - One client is allowed 30 error queries per minute
#' See [query limits section](https://www.mediawiki.org/wiki/Wikidata_Query_Service/User_Manual#Query_limits)
#' in the WDQS user manual for more information.
#' @seealso [get_example]
#' @export
query_wikidata <- function(sparql_query, format = c("simple", "smart")) {
  format <- format[1]
  if (!format %in% c("simple", "smart")) {
    stop("`format` must be either \"simple\" or \"smart\"")
  }
  output <- lapply(sparql_query, function(sparql_query) {
    rate_limited_query <- wdqs_requester()
    if (format == "simple") {
      response <- rate_limited_query(sparql_query, httr::add_headers(Accept = "text/csv"))
      httr::stop_for_status(response)
      if (httr::http_type(response) == "text/csv") {
        content <- httr::content(response, as = "text", encoding = "UTF-8")
        return(readr::read_csv(content))
      } else {
        stop("returned response is not formatted as a CSV")
      }
    } else {
      response <- rate_limited_query(sparql_query, httr::add_headers(Accept = "application/sparql-results+json"))
      httr::stop_for_status(response)
      if (httr::http_type(response) == "application/sparql-results+json") {
        content <- httr::content(response, as = "text", encoding = "UTF-8")
        temp <- jsonlite::fromJSON(content, simplifyVector = FALSE)
      }
      if (length(temp$results$bindings) > 0) {
        data_frame <- purrr::map_dfr(temp$results$bindings, function(binding) {
          return(purrr::map_chr(binding, ~ .x$value))
        })
        datetime_columns <- purrr::map_lgl(temp$results$bindings[[1]], function(binding) {
          if ("datatype" %in% names(binding)) {
            return(binding[["datatype"]] == "http://www.w3.org/2001/XMLSchema#dateTime")
          } else {
            return(FALSE)
          }
        })
        data_frame <- dplyr::mutate_if(
          .tbl = data_frame,
          .predicate = datetime_columns,
          .funs = as.POSIXct,
          format = "%Y-%m-%dT%H:%M:%SZ", tz = "GMT"
        )
      } else {
        data_frame <- dplyr::as_tibble(
          matrix(
            character(),
            nrow = 0, ncol = length(temp$head$vars),
            dimnames = list(c(), unlist(temp$head$vars))
          )
        )
      }
      return(data_frame)
    }
  })
  if (length(output) == 1) {
    return(output[[1]])
  } else {
    if (!is.null(names(sparql_query))) {
      names(output) <- names(sparql_query)
    } else {
      names(output) <- NULL
    }
    return(output)
  }
}
