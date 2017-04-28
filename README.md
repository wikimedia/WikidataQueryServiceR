# WikidataQueryServiceR

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/WikidataQueryServiceR)](https://cran.r-project.org/package=WikidataQueryServiceR)
[![CRAN Total Downloads](https://cranlogs.r-pkg.org/badges/grand-total/WikidataQueryServiceR)](https://cran.r-project.org/package=WikidataQueryServiceR)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This is an R wrapper for the [Wikidata Query Service (WDQS)](https://www.mediawiki.org/wiki/Wikidata_query_service) which provides a way for tools to query [Wikidata](https://www.wikidata.org/wiki/Wikidata:Main_Page) via [SPARQL](https://en.wikipedia.org/wiki/SPARQL) (see the beta at https://query.wikidata.org/). It is written in and for R, and was inspired by Oliver Keyes' [WikipediR](https://github.com/Ironholds/WikipediR) and [WikidataR](https://github.com/Ironholds/WikidataR) packages.

__Author:__ Mikhail Popov (Wikimedia Foundation)<br/> 
__License:__ [MIT](http://opensource.org/licenses/MIT)<br/>
__Status:__ Active

## Installation

```R
install.packages("WikidataQueryServiceR")
```
    
To install the development version:

```R
# install.packages(c("devtools", "httr", "dplyr", "jsonlite"))
devtools::install_github("bearloga/WikidataQueryServiceR")
```

## Example

In this example, we find an "instance of" ([P31](https://www.wikidata.org/wiki/Property:P31)) "film" ([Q11424](https://www.wikidata.org/wiki/Q11424)) that has the label "The Cabin in the Woods" ([Q45394](https://www.wikidata.org/wiki/Q45394)), get its genres ([P136](https://www.wikidata.org/wiki/Property:P136)), and then use [WDQS label service](https://www.mediawiki.org/wiki/Wikidata_query_service/User_Manual#Label_service) to return the genre labels.

```R
sparql_query <- 'PREFIX wd: <http://www.wikidata.org/entity/>
PREFIX wdt: <http://www.wikidata.org/prop/direct/>
PREFIX wikibase: <http://wikiba.se/ontology#>
SELECT DISTINCT ?genre ?genreLabel WHERE {
  SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
  ?film wdt:P31 wd:Q11424.
  ?film rdfs:label "The Cabin in the Woods"@en.
  ?film wdt:P136 ?genre.
}'
WikidataQueryServiceR::query_wikidata(sparql_query)
# 5 rows were returned by WDQS
```

|genre                                   |genreLabel           |
|:---------------------------------------|:--------------------|
|http://www.wikidata.org/entity/Q200092  |horror film          |
|http://www.wikidata.org/entity/Q471839  |science fiction film |
|http://www.wikidata.org/entity/Q224700  |comedy horror        |
|http://www.wikidata.org/entity/Q859369  |comedy-drama         |
|http://www.wikidata.org/entity/Q1342372 |monster film         |

For more example SPARQL queries, see [this page](https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service/queries/examples) on [Wikidata](https://www.wikidata.org/wiki/Wikidata:Main_Page).

`query_wikidata()` can accept multiple queries, returning a (potentially named) list of data frames. If the vector of SPARQL queries is named, the results will inherit those names.

### Extracting and running example SPARQL queries

This package does not rely on the [rvest](https://cran.r-project.org/package=rvest) and [urltools](https://cran.r-project.org/package=urltools) R packages for core functionality, but if the user has them installed then there is a bonus function for scraping [the examples page](https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service/queries/examples) and extracting SPARQL queries.

```R
# install.packages(c("rvest", "urltools"))
sparql_query <- scrape_example(c("Cats", "Horses", "Largest cities with female mayor"))
cat(sparql_query[["Largest cities with female mayor"]])
```

```SPARQL
# Largest cities with female mayor
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

Now we can run all three scraped SPARQL queries and get back three data.frames:

```R
results <- query_wikidata(sparql_query)
# 113 rows were returned by WDQS
# 6677 rows were returned by WDQS
# 10 rows were returned by WDQS
results$`Largest cities with female mayor`
```

|city                                  |cityLabel |mayor                                    |mayorLabel             |
|:-------------------------------------|:---------|:----------------------------------------|:----------------------|
|http://www.wikidata.org/entity/Q1490  |Tokyo     |http://www.wikidata.org/entity/Q261703   |Yuriko Koike           |
|http://www.wikidata.org/entity/Q1156  |Mumbai    |http://www.wikidata.org/entity/Q18218029 |Snehal Ambekar         |
|http://www.wikidata.org/entity/Q38283 |Yokohama  |http://www.wikidata.org/entity/Q529363   |Fumiko Hayashi         |
|http://www.wikidata.org/entity/Q2807  |Madrid    |http://www.wikidata.org/entity/Q19592761 |Manuela Carmena        |
|http://www.wikidata.org/entity/Q11462 |Surabaya  |http://www.wikidata.org/entity/Q12522317 |Tri Rismaharini        |
|http://www.wikidata.org/entity/Q220   |Rome      |http://www.wikidata.org/entity/Q23766020 |Virginia Raggi         |
|http://www.wikidata.org/entity/Q90    |Paris     |http://www.wikidata.org/entity/Q2851133  |Anne Hidalgo           |
|http://www.wikidata.org/entity/Q16555 |Houston   |http://www.wikidata.org/entity/Q213847   |Annise Parker          |
|http://www.wikidata.org/entity/Q1563  |Havana    |http://www.wikidata.org/entity/Q6774124  |Marta Hernández Romero |
|http://www.wikidata.org/entity/Q19660 |Bucharest |http://www.wikidata.org/entity/Q16593781 |Gabriela Fireaa        |

## Additional Information

Please note that this project is released with a [Contributor Code of Conduct](https://github.com/bearloga/WikidataQueryServiceR/blob/master/CONDUCT.md). By participating in this project you agree to abide by its terms.
