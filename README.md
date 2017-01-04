# WikidataQueryServiceR

This is an R wrapper for the [Wikidata Query Service (WDQS)](https://www.mediawiki.org/wiki/Wikidata_query_service) which provides a way for tools to query [Wikidata](https://www.wikidata.org/wiki/Wikidata:Main_Page) via [SPARQL](https://en.wikipedia.org/wiki/SPARQL) (see the beta at https://query.wikidata.org/). It is written in and for R, and was inspired by Oliver Keyes's [WikipediR](https://github.com/Ironholds/WikipediR) and [WikidataR](https://github.com/Ironholds/WikidataR) packages.

__Author:__ Mikhail Popov (Wikimedia Foundation)<br/> 
__License:__ [MIT](http://opensource.org/licenses/MIT)<br/>
__Status:__ In development

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
query_wikidata(sparql_query)
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

## Installation

This R package depends on [httr](https://cran.r-project.org/package=httr), [dplyr](https://cran.r-project.org/package=dplyr), and [jsonlite](https://cran.r-project.org/package=jsonlite) R packages (and their dependencies).
    
To install the development version:

```R
# install.packages(c("devtools", "httr", "dplyr", "jsonlite"))
devtools::install_github("bearloga/WikidataQueryServiceR")
```

## Additional Information

Please note that this project is released with a [Contributor Code of Conduct](https://github.com/bearloga/WikidataQueryServiceR/blob/master/CONDUCT.md). By participating in this project you agree to abide by its terms.
