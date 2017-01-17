#' @title Send one or more SPARQL queries to WDQS
#' @description Makes a GET request to Wikidata Query Service SPARQL endpoint.
#' @param sparql_query SPARQL query (can be a vector of queries)
#' @param format "simple" uses CSV and returns pure character data frame, while
#'   "smart" fetches JSON-formatted data and returns a data frame with datetime
#'   columns converted to POSIXlt
#' @param ... Additional parameters to supply to \code{\link[httr]{GET}}
#' @return A data.frame
#' @examples
#' # Cats on Wikidata:
#' sparql_query <- 'SELECT ?item ?itemLabel
#' WHERE
#' {
#'   ?item wdt:P31 wd:Q146 .
#'   SERVICE wikibase:label { bd:serviceParam wikibase:language "en" }
#' }
#' LIMIT 10'
#' query_wikidata(sparql_query)
#'
#' \dontrun{
#' sparql_query <- "#Recent Events
#' SELECT ?event ?eventLabel ?date
#' WHERE
#' {
#'   # find events
#'   ?event wdt:P31/wdt:P279* wd:Q1190554.
#'   # with a point in time or start date
#'   OPTIONAL { ?event wdt:P585 ?date. }
#'   OPTIONAL { ?event wdt:P580 ?date. }
#'   # but at least one of those
#'   FILTER(BOUND(?date) && DATATYPE(?date) = xsd:dateTime).
#'   # not in the future, and not more than 31 days ago
#'   BIND(NOW() - ?date AS ?distance).
#'   FILTER(0 <= ?distance && ?distance < 31).
#'   # and get a label as well
#'   OPTIONAL {
#'     ?event rdfs:label ?eventLabel.
#'     FILTER(LANG(?eventLabel) = \"en\").
#'   }
#' }
#' # limit to 10 results so we don't timeout
#' LIMIT 10"
#'
#' # "smart" format converts all datetime columns to POSIXlt
#' query_wikidata(sparql_query, format = "smart")
#' }
#' @export
query_wikidata <- function(sparql_query, format = c("simple", "smart"), ...) {
  if (!format[1] %in% c("simple", "smart")) {
    stop("`format` must be either \"simple\" or \"smart\"")
  }
  output <- lapply(sparql_query, function(sparql_query) {
    if (format[1] == "simple") {
      response <- httr::GET(
        url = "https://query.wikidata.org/sparql",
        query = list(query = sparql_query),
        httr::add_headers(Accept = "text/csv"),
        httr::user_agent("https://github.com/bearloga/WikidataQueryServiceR"),
        ...
      )
      httr::stop_for_status(response)
      if (httr::http_type(response) == "text/csv") {
        con <- textConnection(httr::content(response, as = "text", encoding = "UTF-8"))
        df <- utils::read.csv(con, header = TRUE, stringsAsFactors = FALSE)
        message(nrow(df), " rows were returned by WDQS")
        return(df)
      } else {
        stop("returned response is not formatted as a CSV")
      }
    } else {
      response <- httr::GET(
        url = "https://query.wikidata.org/sparql",
        query = list(query = sparql_query),
        format = "json",
        httr::user_agent("https://github.com/bearloga/WikidataQueryServiceR"),
        ...
      )
      httr::stop_for_status(response)
      if (httr::http_type(response) == "application/sparql-results+json") {
        temp <- jsonlite::read_json(httr::content(response, as = "text", encoding = "UTF-8"))
      }
      httr::stop_for_status(response)
      if (length(temp$results$bindings) > 0) {
        df <- as.data.frame(dplyr::bind_rows(lapply(temp$results$bindings, function(x) {
          return(lapply(x, function(y) { return(y$value) }))
        })))
        datetime_cols <- vapply(temp$results$bindings[[1]], function(x) {
          if ("datatype" %in% names(x)) {
            return(x$datatype == "http://www.w3.org/2001/XMLSchema#dateTime")
          } else {
            return(FALSE)
          }
        }, FALSE)
        if (any(datetime_cols)) {
          for (datetime_col in which(datetime_cols)) {
            df[[datetime_col]] <- as.POSIXlt(df[[datetime_col]], format = "%Y-%m-%dT%H:%M:%SZ", tz = "GMT")
          }
        }
        message(nrow(df), " rows were returned by WDQS")
        return(df)
      } else {
        message("0 rows were returned by WDQS")
        return(data.frame(matrix(character(), nrow = 0, ncol = length(temp$head$vars),
                                 dimnames = list(c(), unlist(temp$head$vars))),
                          stringsAsFactors = FALSE))
      }
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
