#' @import ratelimitr
wdqs_requester <- function() {
  req <- function(query, ...) {
    httr::POST(
      url = "https://query.wikidata.org/sparql",
      query = list(query = query),
      httr::user_agent("https://github.com/bearloga/WikidataQueryServiceR"),
      ...
    )
  }
  return(limit_rate(req, rate(n = 30, period = 60)))
}
