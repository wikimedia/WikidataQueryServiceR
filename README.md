WikidataQueryServiceR
================

-   [Installation](#installation)
-   [Usage](#usage)
    -   [Example: fetching genres of a particular movie](#example-fetching-genres-of-a-particular-movie)
    -   [Fetching queries from Wikidata's examples page](#fetching-queries-from-wikidatas-examples-page)
-   [Links for learning SPARQL](#links-for-learning-sparql)
-   [Additional Information](#additional-information)

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/WikidataQueryServiceR)](https://cran.r-project.org/package=WikidataQueryServiceR) [![CRAN Total Downloads](https://cranlogs.r-pkg.org/badges/grand-total/WikidataQueryServiceR)](https://cran.r-project.org/package=WikidataQueryServiceR) [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This is an R wrapper for the [Wikidata Query Service (WDQS)](https://www.mediawiki.org/wiki/Wikidata_query_service) which provides a way for tools to query [Wikidata](https://www.wikidata.org/wiki/Wikidata:Main_Page) via [SPARQL](https://en.wikipedia.org/wiki/SPARQL) (see the beta at <https://query.wikidata.org/>). It is written in and for R, and was inspired by Oliver Keyes' [WikipediR](https://github.com/Ironholds/WikipediR) and [WikidataR](https://github.com/Ironholds/WikidataR) packages.

**Author:** Mikhail Popov (Wikimedia Foundation)<br/> **License:** [MIT](http://opensource.org/licenses/MIT)<br/> **Status:** Active

Installation
------------

``` r
install.packages("WikidataQueryServiceR")
```

To install the development version:

``` r
# install.packages(c("devtools", "httr", "dplyr", "jsonlite"))
devtools::install_github("bearloga/WikidataQueryServiceR")
```

Usage
-----

``` r
library(WikidataQueryServiceR)
```

You submit SPARQL queries using the `query_wikidata()` function.

### Example: fetching genres of a particular movie

In this example, we find an "instance of" ([P31](https://www.wikidata.org/wiki/Property:P31)) "film" ([Q11424](https://www.wikidata.org/wiki/Q11424)) that has the label "The Cabin in the Woods" ([Q45394](https://www.wikidata.org/wiki/Q45394)), get its genres ([P136](https://www.wikidata.org/wiki/Property:P136)), and then use [WDQS label service](https://www.mediawiki.org/wiki/Wikidata_query_service/User_Manual#Label_service) to return the genre labels.

``` r
query_wikidata('SELECT DISTINCT
  ?genre ?genreLabel
WHERE {
  ?film wdt:P31 wd:Q11424.
  ?film rdfs:label "The Cabin in the Woods"@en.
  ?film wdt:P136 ?genre.
  SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
}')
```

    ## 5 rows were returned by WDQS

| genre                                     | genreLabel           |
|:------------------------------------------|:---------------------|
| <http://www.wikidata.org/entity/Q471839>  | science fiction film |
| <http://www.wikidata.org/entity/Q1342372> | monster film         |
| <http://www.wikidata.org/entity/Q224700>  | comedy horror        |
| <http://www.wikidata.org/entity/Q200092>  | horror film          |
| <http://www.wikidata.org/entity/Q859369>  | comedy-drama         |

For more example SPARQL queries, see [this page](https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service/queries/examples) on [Wikidata](https://www.wikidata.org/wiki/Wikidata:Main_Page).

`query_wikidata()` can accept multiple queries, returning a (potentially named) list of data frames. If the vector of SPARQL queries is named, the results will inherit those names.

### Fetching queries from Wikidata's examples page

The package provides a [WikipediR](https://github.com/Ironholds/WikipediR/)-based function for getting SPARQL queries from the [WDQS examples page](https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service/queries/examples).

``` r
sparql_query <- get_example(c("Cats", "Horses", "Largest cities with female mayor"))
```

``` r
sparql_query[["Largest cities with female mayor"]]
```

``` sparql
 #added before 2016-10
#TEMPLATE={"template":"Largest ?c with ?sex head of government","variables":{"?sex":{"query":" SELECT ?id WHERE { ?id wdt:P31 wd:Q48264 .  } "},"?c":{"query":"SELECT DISTINCT ?id WHERE {  ?c wdt:P31 ?id.  ?c p:P6 ?mayor. }"} } }
SELECT DISTINCT ?city ?cityLabel ?mayor ?mayorLabel 
WHERE 
{
  BIND(wd:Q6581072 AS ?sex)
  BIND(wd:Q515 AS ?c)
    ?city wdt:P31/wdt:P279* ?c .  # find instances of subclasses of city
    ?city p:P6 ?statement .            # with a P6 (head of goverment) statement
    ?statement ps:P6 ?mayor .          # ... that has the value ?mayor
    ?mayor wdt:P21 ?sex .       # ... where the ?mayor has P21 (sex or gender) female
    FILTER NOT EXISTS { ?statement pq:P582 ?x }  # ... but the statement has no P582 (end date) qualifier
     
    # Now select the population value of the ?city
    # (wdt: properties use only statements of "preferred" rank if any, usually meaning "current population")
    ?city wdt:P1082 ?population .
    # Optionally, find English labels for city and mayor:
    SERVICE wikibase:label {
        bd:serviceParam wikibase:language "en" .
    }
}
ORDER BY DESC(?population)
LIMIT 10 
```

Now we can run all three extracted SPARQL queries and get back three data.frames:

``` r
results <- query_wikidata(sparql_query)
```

    ## 116 rows were returned by WDQS

    ## 6951 rows were returned by WDQS

    ## 10 rows were returned by WDQS

``` r
results$`Largest cities with female mayor`[, c("cityLabel", "mayorLabel")]
```

| cityLabel    | mayorLabel         |
|:-------------|:-------------------|
| Tokyo        | Yuriko Koike       |
| Mumbai       | Snehal Ambekar     |
| Yokohama     | Fumiko Hayashi     |
| Caracas      | Helen Fernández    |
| Madrid       | Manuela Carmena    |
| Surabaya     | Tri Rismaharini    |
| Rome         | Virginia Raggi     |
| Paris        | Anne Hidalgo       |
| Houston      | Annise Parker      |
| Antananarivo | Lalao Ravalomanana |

Links for learning SPARQL
-------------------------

-   [A beginner-friendly course for SPARQL](https://www.wikidata.org/wiki/Wikidata:A_beginner-friendly_course_for_SPARQL)
-   Building a SPARQL query: [Museums on Instagram](https://www.wikidata.org/wiki/Help:SPARQL/Building_a_query/Museums_on_Instagram)
-   [SPARQL Query Examples](https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service/queries/examples) for WDQS
-   [Using SPARQL to access Linked Open Data](http://programminghistorian.org/lessons/graph-databases-and-SPARQL) by Matthew Lincoln
-   Interesting or illustrative [SPARQL queries](https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service/queries) for Wikidata
-   Wikidata [2016 SPARQL Workshop](https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service/2016_SPARQL_Workshop)
-   [Wikidata SPARQL Query video tutorial](https://www.youtube.com/watch?v=1jHoUkj_mKw) by Navino Evans
-   *[Learning SPARQL](http://www.learningsparql.com/)* by Bob DuCharme
-   [WDQS User Manual](https://www.mediawiki.org/wiki/Wikidata_query_service/User_Manual)

Additional Information
----------------------

Please note that this project is released with a [Contributor Code of Conduct](https://github.com/bearloga/WikidataQueryServiceR/blob/master/CONDUCT.md). By participating in this project you agree to abide by its terms.
