library(stringr)

updateSparqlQuery <- function(endpoint_url="http://localhost:3030/tutorial2-tdb/", 
                              update_value = "3000",
                              update_iri = "http://example.com/tutorial2/description/statedictionary#orbiter-spacecraft.isp"
                              ){
  
  graph_iri <- str_extract(update_iri, "^[^#]*") # extract strings before "#"
  
  ### delete query template
  query_string_delete_tdb <- '
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX sa:  <http://example.com/tutorial2/vocabulary/stateanalysis#>

delete {
  graph <$GRAPHIRI> {
    ?analysisTarget sa:hasStateValue ?beforeValue .
  }
}

where{
    BIND(<$UPDATEIRI> AS ?analysisTarget)

  		?analysisTarget a owl:NamedIndividual ;
      			sa:hasStateValue ?beforeValue .
}
'

  ### Insert query template
  query_string_insert_tdb <- '

PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX sa:  <http://example.com/tutorial2/vocabulary/stateanalysis#>

insert { 
  graph <$GRAPHIRI> {
    ?analysisTarget a owl:NamedIndividual ;
      			sa:hasStateValue ?afterValue .
		}
}

where{
    BIND(<$UPDATEIRI> AS ?analysisTarget)
    BIND("$UPDATEVALUE" AS ?afterValue) 
 
}
'

  # substitute delete iri
  query_string_delete_tdb <- str_replace(query_string_delete_tdb, "\\$UPDATEIRI", update_iri)
  query_string_delete_tdb <- str_replace(query_string_delete_tdb, "\\$GRAPHIRI", graph_iri)

  # substitute insert iri and value
  query_string_insert_tdb <- str_replace(query_string_insert_tdb, "\\$UPDATEVALUE", update_value)
  query_string_insert_tdb <- str_replace(query_string_insert_tdb, "\\$UPDATEIRI", update_iri)
  query_string_insert_tdb <- str_replace(query_string_insert_tdb, "\\$GRAPHIRI", graph_iri)
  
  
  df_ret <- data.frame(
    query_string_delete_tdb = query_string_delete_tdb,
    query_string_insert_tdb = query_string_insert_tdb,
    return_message_delete = "",
    return_message_insert = ""
  )
  ret <- "return message"
  return(df_ret)
}
