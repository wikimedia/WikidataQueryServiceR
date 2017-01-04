# WikidataQueryServiceR

This is an R wrapper for the [Wikidata Query Service (WDQS)](https://www.mediawiki.org/wiki/Wikidata_query_service) which provides a way for tools to query [Wikidata](https://www.wikidata.org/wiki/Wikidata:Main_Page) via [SPARQL](https://en.wikipedia.org/wiki/SPARQL) (see the beta at https://query.wikidata.org/). It is written in and for R, and was inspired by Oliver Keyes' [WikipediR](https://github.com/Ironholds/WikipediR) and [WikidataR](https://github.com/Ironholds/WikidataR) packages.

__Author:__ Mikhail Popov (Wikimedia Foundation)<br/> 
__License:__ [MIT](http://opensource.org/licenses/MIT)<br/>
__Status:__ Active, early in development

## Example

```R
# https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service/queries/examples#Cats
sparql_query <- 'SELECT ?item ?itemLabel
WHERE
{
  ?item wdt:P31 wd:Q146 .
  SERVICE wikibase:label { bd:serviceParam wikibase:language "en" }
}
LIMIT 10'
query_wikidata(sparql_query) # 10 rows were returned by WDQS
```

|item                                     |itemLabel    |
|:----------------------------------------|:------------|
|http://www.wikidata.org/entity/Q25471040 |Pixel        |
|http://www.wikidata.org/entity/Q27190410 |Gladstone    |
|http://www.wikidata.org/entity/Q27739753 |Sister Cream |
|http://www.wikidata.org/entity/Q27744042 |Bob          |
|http://www.wikidata.org/entity/Q27745002 |Musashi      |
|http://www.wikidata.org/entity/Q27745006 |Leo          |
|http://www.wikidata.org/entity/Q27745008 |Luca         |
|http://www.wikidata.org/entity/Q27745009 |Seri         |
|http://www.wikidata.org/entity/Q27745011 |Marble       |
|http://www.wikidata.org/entity/Q28114532 |Q28114532    |

For more example SPARQL queries, see [this page](https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service/queries/examples) on [Wikidata](https://www.wikidata.org/wiki/Wikidata:Main_Page).

### Extracting and running example SPARQL queries

This package does not rely on the [rvest](https://cran.r-project.org/package=rvest) and [urltools](https://cran.r-project.org/package=urltools) R packages for core functionality, but if the user has them installed then there is a bonus function for scraping [the examples page](https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service/queries/examples) and extracting SPARQL queries.

```R
# install.packages(c("rvest", "urltools"))
sparql_query <- scrape_example("Largest cities with female mayor")
cat(sparql_query)
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

```R
query_wikidata(sparql_query) # 10 rows were returned by WDQS
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

## Installation

This R package depends on [httr](https://cran.r-project.org/package=httr), [dplyr](https://cran.r-project.org/package=dplyr), and [jsonlite](https://cran.r-project.org/package=jsonlite) R packages (and their dependencies).
    
To install the development version:

```R
# install.packages(c("devtools", "httr", "dplyr", "jsonlite"))
devtools::install_github("bearloga/WikidataQueryServiceR")
```

## Additional Information

Please note that this project is released with a [Contributor Code of Conduct](https://github.com/bearloga/WikidataQueryServiceR/blob/master/CONDUCT.md). By participating in this project you agree to abide by its terms.
