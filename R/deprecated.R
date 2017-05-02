#' @title Deprecated functions
#' @description Why did I have to go and make things so deprecated?
#' @name WDQSR-deprecated
NULL

#' @inheritParams get_example
#' @param ... ignored (kept for backwards-compatibility)
#' @describeIn WDQSR-deprecated use [get_example] instead which employs [WikipediR::page_content]
#' @export
scrape_example <- function(example_name, ...) {
  .Deprecated("get_example")
  return(get_example(example_name))
}
