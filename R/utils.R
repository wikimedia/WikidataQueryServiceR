#' @title Get an example SPARQL query from Wikidata
#' @description Gets the specified example(s) from
#'   [SPARQL query service examples page](https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service/queries/examples)
#'   using [Wikidata's MediaWiki API](https://www.wikidata.org/w/api.php).
#' @details If you are planning on extracting multiple examples, please provide
#'   all the names as a single vector for efficiency.
#' @param example_name the names of the examples as they appear on
#'   [this page](https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service/queries/examples)
#' @return The SPARQL query as a character vector.
#' @examples
#' \dontrun{
#' sparql_query <- extract_example(c("Cats", "Horses"))
#' query_wikidata(sparql_query)
#' # returns a named list with two data frames
#' # one called "Cats" and one called "Horses"
#'
#' sparql_query <- extract_example("Largest cities with female mayor")
#' cat(sparql_query)
#' query_wikidata(sparql_query)
#' }
#' @seealso [query_wikidata]
#' @export
get_example <- function(example_name) {
  content <- WikipediR::page_content(
    domain = "www.wikidata.org",
    page_name = "Wikidata:SPARQL query service/queries/examples",
    as_wikitext = TRUE
  )
  wikitext <- strsplit(content$parse$wikitext$`*`, "\n")[[1]]
  wikitext <- wikitext[wikitext != ""]
  examples <- purrr::map(example_name, function(example_name) {
    regex <- paste0(
      "^={2,}\\s?(<translate><!--T:[0-9]+-->)?\\s?",
      rex::escape(example_name),
      "\\s?(</translate>)?\\s?={2,}$"
    )
    heading_line <- which(grepl(regex, wikitext, fixed = FALSE))
    start_line <- which(grepl("{{SPARQL", wikitext[(heading_line + 1):length(wikitext)], fixed = TRUE))[1]
    end_line <- which(grepl("}}", wikitext[(heading_line + start_line + 1):length(wikitext)], fixed = TRUE))[1]
    query <- paste0(wikitext[(heading_line + start_line):(heading_line + start_line + end_line - 1)], collapse = "\n")
    return(sub("^\\s*\\{\\{SPARQL2?\\n?\\|query\\=", "", query))
  })
  names(examples) <- example_name
  return(examples)
}
