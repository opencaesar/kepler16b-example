print("for oml-vision 0.2.6")
print("this code is updating in kepler-16b=IMCE")
print("this code is not same as open-source-rover")

# Reusable wrapper functions for oml-vision
library(tidyverse)
library(jsonlite)

###############################################################################
#### for sparql
generatePrefix <- function(df_prefix=NULL){

  if(is.null(df_prefix)){
    df_prefix <- data.frame(
      prefix = c("base",
                 "mission"),
      iri = c("http://imce.jpl.nasa.gov/foundation/base#",
              "http://imce.jpl.nasa.gov/foundation/mission#")
    )
  }
  # generate PREFIX Strings
  df_prefix <- df_prefix |>
    mutate(querystring = paste0("PREFIX ", prefix, ":        <", iri, ">\n"))

  text_instance <- ""
  for(string in df_prefix$querystring){
    text_instance <- paste0(text_instance, string)
  }
  return(text_instance)
}


generateQueryDecomposition <- function(df, df_prefix){
  
  text_instance <- ""
  text_instance <- paste0(text_instance,
                          generatePrefix(df_prefix),
                          "\n"
  )
  text_instance <- paste0(text_instance,
                          "SELECT DISTINCT ",
                          "?", df$parent, " ",
                          "?", df$parent_instancename, " ",
                          "?", df$parent_id, " ",
                          "?", df$parent_name, " ",
                          "?", df$child, " ",
                          "?", df$child_instancename, " ",
                          "?", df$child_id, " ",
                          "?", df$child_name, " ",
                          "\n",
                          "WHERE {","\n",
                          "\n",
                          "  VALUES ?componentType { ", df$target_type, " }", "\n",
                          "\n"
  )
  text_instance <- paste0(text_instance,
                          "  ?", df$parent, " a ?componentType ;","\n",
                          "    base:hasIdentifier ?", df$parent_id, " ;\n",
                          "    base:hasCanonicalName ?", df$parent_name, " ;\n",
                          "\n",
                          "  OPTIONAL{\n",
                          "    ?", df$parent, " ", df$target_relation, " ?", df$child, " ;\n",
                          "    OPTIONAL{\n",
                          "      ?", df$child, " base:hasIdentifier ?", df$child_id, " ;\n",
                          "          base:hasCanonicalName ?", df$child_name, " .\n",
                          "    }\n",
                          "  }\n",
                          "\n\n"
  )
  
  text_instance <- paste0(text_instance,
                          "  BIND(STRAFTER(STR(?", df$parent, "), \"#\") AS ?", df$parent_instancename, ") .\n",
                          "  BIND(STRAFTER(STR(?", df$child, "), \"#\") AS ?", df$child_instancename, ") .\n"
  )
  text_instance <- paste0(text_instance,
                          " }\n",
                          "ORDER BY ?", df$parent_id, "\n"
  )                          
  
  
}


###############################################################################
#### for DiagramLayout.json


generateDiagramLayoutDecomposition <- function(df){
  
  # text_instance <- ""
  # text_instance <- paste0(text_instance,
  #                         "  \"", df$diagram_id, "\": {\n",
  #                         "    \"name\": \"", df$diagram_id, "\",\n",
  #                         "    \"queries\": {\n",
  #                         #                "      \"", df$diagram_id, "\": \"", df$queryfile, "\",\n",
  #                         "      \"node\": \"", df$queryfile, "\",\n",
  #                         "      \"edge\": \"", df$queryfile, "\"\n",
  #                         "    },\n",
  #                         "    \"rowMapping\": {\n",
  #                         "      \"id\": \"node\",\n",
  #                         "      \"name\": \"Parent\",\n",
  #                         "      \"labelFormat\": \"{", df$parent_node_labelFormat, "}\",\n",
  #                         "      \"nodeColor\": \"", df$parent_node_nodeColor, "\",\n",
  #                         "      \"nodeTextColor\": \"", df$parent_node_nodeTextColor, "\",\n",
  #                         "      \"nodeType\": \"{", df$parent_node_nodeType, "}\",\n",
  #                         "      \"edgeMatchKey\": \"", df$parent_edgeMatchKey, "\"\n",
  #                         "    },\n",
  #                         "    \"edges\": [\n",
  #                         "      {\n",
  #                         "        \"id\": \"edge\",\n",
  #                         "        \"name\": \"Edge\",\n",
  #                         "        \"animated\": true,\n",
  #                         "        \"labelFormat\": \"", df$edge_labelFormat, "\",\n",
  #                         "        \"legendItems\": \"{", df$edge_legendItems, "}\",\n",
  #                         "        \"sourceKey\": \"", df$parent_instancename, "\",\n",
  #                         "        \"targetKey\": \"", df$child_instancename, "\"\n",
  #                         "      }\n",
  #                         "    ]\n",
  #                         "  }\n"
  # )

  new_data <- list(
    name = df$diagram_id,
    queries = list(
      node = df$queryfile,
      edge = df$queryfile
    ),
    rowMapping = list(
      id = "node",
      name = "Parent",
      labelFormat = paste0("{", df$parent_node_labelFormat, "}"),
      nodeColor = df$parent_node_nodeColor,
      nodeTextColor = df$parent_node_nodeTextColor,
      nodeType = df$parent_node_nodeType,
      edgeMatchKey = df$parent_edgeMatchKey
    ),
    edges = list(list(
      id = "edge",
      name = "Edge",
      animated = TRUE,
      labelFormat = df$edge_labelFormat,
      legendItems = df$edge_legendItems,
      sourceKey = df$parent_instancename,
      targetKey = df$child_instancename
    ))
  )
  
  json_string <- toJSON(new_data, pretty = TRUE, auto_unbox = TRUE)
  
}



###############################################################################
#### For Page.json
generatePageDiagram <- function(df){
  
  text_instance <- ""
  text_instance <- paste0(text_instance,
                          "        {\n",
                          "          \"title\": \"", df$diagram_id, "\",\n",
                          "          \"treeIcon\": \"outline-view-icon\",\n",
                          "          \"path\": \"", df$diagram_id, "\",\n",
                          "          \"isDiagram\": true\n",
                          "        },"
  )
}

###############################################################################
#
omlvisionDecomposition <- function(omlrepo,
                                   df_prefix = NULL,
                                   viewname = "auto",
                                   title = "title",
                                   targetConcept = c("structure:System structure:Subsystem structure:Assembly"),
                                   targetRelation = "base:isContainedIn",
                                   nodeColor = "green",
                                   nodeTextColor = "white"){
  
  df_keys <- data.frame(
    queryfile = paste0(viewname, ".sparql"),
    parent = c("c1"),
    parent_instancename = c("c1_instancename"),
    parent_id = c("c1_id"),
    parent_name = c("c1_name"),
    child_instancename = c("c2_instancename"),
    child = c("c2"),
    child_id = c("c2_id"),
    child_name = c("c2_name"),
    target_type = targetConcept,
    target_relation = targetRelation,
    diagram_id = viewname
  )
  
  
  df_keys <- df_keys %>%
    mutate(parent_node_labelFormat = parent_instancename) %>%
    mutate(parent_node_nodeColor = nodeColor) %>%
    mutate(parent_node_nodeTextColor = nodeTextColor) %>%
    mutate(parent_node_nodeType = "NA") %>% # Assembly or Subsystem
    mutate(parent_edgeMatchKey = parent_instancename) %>%
    mutate(edge_labelFormat = targetRelation) %>%
    mutate(edge_legendItems = child_instancename)
  
  df_keys$querytext <- generateQueryDecomposition(df_keys, df_prefix)
  df_keys$diagramLayouttext <- generateDiagramLayoutDecomposition(df_keys)
  df_keys$pagetext <- generatePageDiagram(df_keys)

  
  outputdir <- paste0(omlrepo,"src/vision/sparql/")
  outputfile <- paste0(outputdir, df_keys$queryfile)
  cat(file=outputfile, df_keys$querytext)
  
  ### Update diagramLayout.json
  #If there is already `df_keys$diagram_id` in diagramLayout.json, update codes to diagramLayouttext
  
  outputdir <- paste0(omlrepo,"src/vision/viewpoints/diagrams/")
  writefile <- paste0(outputdir, viewname, ".json")
  # writefile <- paste0(outputdir, "diagramLayouts2.json")

  parsedjson <- fromJSON(df_keys$diagramLayouttext)
  
  diagramLayoutjson <- parsedjson
  
  # Generate diagramLayouts.json
  write_json(diagramLayoutjson, writefile, pretty = TRUE, auto_unbox = TRUE)
  
  # for oml-vision 0.2.6
  text_instance <- read_file(writefile)
  text_instance <- paste0("{\n", "\"", viewname, "\": ", text_instance, "}\n")
  cat(file=writefile, text_instance)
  
  ###############################################################################
  # page.jsonを読み込んで、pathが存在しなかったら追加する処理が欲しい。

  outputdir <- paste0(omlrepo,"src/vision/viewpoints/")
  readfile <- paste0(outputdir, "pages.json")
  # writefile <- paste0(outputdir, "diagramLayouts2.json")
  writefile <- readfile
  
  pagesJson <- read_json(readfile)
  
  index <- NA
  for(i in 1:length(pagesJson[[2]]$children)){
    if( pagesJson[[2]]$children[[i]]$path == viewname){
      # Nothing to do, you already have a page
      index <- i
    }
  }
  if(is.na(index)){
    index <- i + 1
  }
  pagesJson[[2]]$children[index][[1]]$title <- title
  pagesJson[[2]]$children[index][[1]]$type <- "diagram"
  pagesJson[[2]]$children[index][[1]]$path <- viewname
  
  
  write_json(pagesJson, writefile, pretty = TRUE, auto_unbox = TRUE)
  
      
  return(df_keys)
}


###############################################################################
#### for sparql
generateQueryRelationMap <- function(df, df_prefix){
  
  text_instance <- ""
  text_instance <- paste0(text_instance,
                          generatePrefix(df_prefix),
                          "\n"
  )

  text_instance <- paste0(text_instance,
                          "SELECT DISTINCT ",
                          "?", df$source, " ",
                          "?", df$source_instancename, " ",
                          # "?", df$source_id, " ",
                          # "?", df$source_name, " ",
                          "?", df$target, " ",
                          "?", df$target_instancename, " ",
                          # "?", df$target_id, " ",
                          # "?", df$target_name, " ",
                          "\n",
                          "WHERE {","\n",
                          "\n",
                          "  VALUES ?componentType { ", df$target_type, " }", "\n",
                          "  VALUES ?relationType { ", df$target_relation, " }", "\n",
                          "\n"
  )
  text_instance <- paste0(text_instance,
                          "  ?", df$source, " a ?componentType ;","\n",
                          #                          "    base:hasIdentifier ?", df$source_id, " ;\n",
                          #                          "    base:hasCanonicalName ?", df$source_name, " ;\n",
                          "\n",
                          "  OPTIONAL{\n",
                          "    ?", df$source, " ?relationType", " ?", df$target, " ;\n",
                          "  }\n",
                          "\n\n"
  )

    
  text_instance <- paste0(text_instance,
                          "  BIND(STRAFTER(STR(?", df$source, "), \"#\") AS ?", df$source_instancename, ") .\n",
                          "  BIND(STRAFTER(STR(?", df$target, "), \"#\") AS ?", df$target_instancename, ") .\n"
  )
  text_instance <- paste0(text_instance,
                          " }\n",
                          "ORDER BY ?", df$source, "\n"
  )                          
  
  
}


###############################################################################
#### for DiagramLayout.json


generateDiagramLayoutRelationMap <- function(df){
  
  # text_instance <- ""
  # text_instance <- paste0(text_instance,
  #                         "  \"", df$diagram_id, "\": {\n",
  #                         "    \"name\": \"", df$diagram_id, "\",\n",
  #                         "    \"queries\": {\n",
  #                         #                "      \"", df$diagram_id, "\": \"", df$queryfile, "\",\n",
  #                         "      \"node\": \"", df$queryfile, "\",\n",
  #                         "      \"edge\": \"", df$queryfile, "\"\n",
  #                         "    },\n",
  #                         "    \"rowMapping\": {\n",
  #                         "      \"id\": \"node\",\n",
  #                         "      \"name\": \"source\",\n",
  #                         "      \"labelFormat\": \"{", df$source_node_labelFormat, "}\",\n",
  #                         "      \"nodeColor\": \"", df$source_node_nodeColor, "\",\n",
  #                         "      \"nodeTextColor\": \"", df$source_node_nodeTextColor, "\",\n",
  #                         "      \"nodeType\": \"{", df$source_node_nodeType, "}\",\n",
  #                         "      \"edgeMatchKey\": \"", df$source_edgeMatchKey, "\"\n",
  #                         "    },\n",
  #                         "    \"edges\": [\n",
  #                         "      {\n",
  #                         "        \"id\": \"edge\",\n",
  #                         "        \"name\": \"Edge\",\n",
  #                         "        \"animated\": true,\n",
  #                         "        \"labelFormat\": \"", df$edge_labelFormat, "\",\n",
  #                         "        \"legendItems\": \"{", df$edge_legendItems, "}\",\n",
  #                         "        \"sourceKey\": \"", df$source_instancename, "\",\n",
  #                         "        \"targetKey\": \"", df$target_instancename, "\"\n",
  #                         "      }\n",
  #                         "    ]\n",
  #                         "  }\n"
  # )
  
  new_data <- list(
    name = df$diagram_id,
    queries = list(
      node = df$queryfile,
      edge = df$queryfile
    ),
    rowMapping = list(
      id = "node",
      name = "source",
      labelFormat = paste0("{", df$source_node_labelFormat, "}"),
      nodeColor = df$source_node_nodeColor,
      nodeTextColor = df$source_node_nodeTextColor,
      nodeType = df$source_node_nodeType,
      edgeMatchKey = df$source_edgeMatchKey
    ),
    edges = list(list(
      id = "edge",
      name = "Edge",
      animated = TRUE,
      labelFormat = df$edge_labelFormat,
      legendItems = df$edge_legendItems,
      sourceKey = df$source_instancename,
      targetKey = df$target_instancename
    ))
  )
  
  json_string <- toJSON(new_data, pretty = TRUE, auto_unbox = TRUE)
  
}


###############################################################################
#
setKeyRelationMap <- function(omlrepo,
                                   viewname = "auto",
                                   title = "title",
                                   targetConcept = c("mission:Component"),
                                   targetRelation = "base:isContainedIn",
                                   nodeColor = "green",
                                   nodeTextColor = "white"){
  
  df_keys <- data.frame(
    queryfile = paste0(viewname, ".sparql"),
    source = c("iri"),
    source_instancename = c("source"),
    # source_id = c("c1_id"),
    # source_name = c("c1_name"),
    target = c("targetIri"),
    target_instancename = c("target"),
    # target_id = c("c2_id"),
    # target_name = c("c2_name"),
    target_type = targetConcept,
    target_relation = targetRelation,
    diagram_id = viewname
  )
  
  
  df_keys <- df_keys %>%
    mutate(source_node_labelFormat = source_instancename) %>%
    mutate(source_node_nodeColor = nodeColor) %>%
    mutate(source_node_nodeTextColor = nodeTextColor) %>%
    mutate(source_node_nodeType = "NA") %>% # Assembly or Subsystem
    mutate(source_edgeMatchKey = source_instancename) %>%
    mutate(edge_labelFormat = targetRelation) %>%
    mutate(edge_legendItems = targetRelation)
  

  
  return(df_keys)
}

###############################################################################
#
omlvisionRelationMap <- function(omlrepo,
                                 df_prefix = NULL,
                                   viewname = "auto",
                                   title = "title",
                                   targetConcept = c("mission:Component"),
                                   targetRelation = "base:isContainedIn",
                                   nodeColor = "green",
                                   nodeTextColor = "white"){
  
  df_keys <- setKeyRelationMap(omlrepo,viewname,title,targetConcept,targetRelation,nodeColor,nodeTextColor)

  # df_keys <- data.frame(
  #   queryfile = paste0(viewname, ".sparql"),
  #   source = c("iri"),
  #   source_instancename = c("source"),
  #   # source_id = c("c1_id"),
  #   # source_name = c("c1_name"),
  #   target = c("targetIri"),
  #   target_instancename = c("target"),
  #   # target_id = c("c2_id"),
  #   # target_name = c("c2_name"),
  #   target_type = targetConcept,
  #   target_relation = targetRelation,
  #   diagram_id = viewname
  # )
  # 
  # 
  # df_keys <- df_keys %>%
  #   mutate(source_node_labelFormat = source_instancename) %>%
  #   mutate(source_node_nodeColor = nodeColor) %>%
  #   mutate(source_node_nodeTextColor = nodeTextColor) %>%
  #   mutate(source_node_nodeType = "NA") %>% # Assembly or Subsystem
  #   mutate(source_edgeMatchKey = source_instancename) %>%
  #   mutate(edge_labelFormat = targetRelation) %>%
  #   mutate(edge_legendItems = target_instancename)
  
  df_keys$querytext <- generateQueryRelationMap(df_keys, df_prefix)
  df_keys$diagramLayouttext <- generateDiagramLayoutRelationMap(df_keys)
  df_keys$pagetext <- generatePageDiagram(df_keys)
  
  
  outputdir <- paste0(omlrepo,"src/vision/sparql/")
  outputfile <- paste0(outputdir, df_keys$queryfile)
  cat(file=outputfile, df_keys$querytext)
  
  ### Update diagramLayout.json
  #If there is already `df_keys$diagram_id` in diagramLayout.json, update codes to diagramLayouttext
  
  outputdir <- paste0(omlrepo,"src/vision/viewpoints/diagrams/")
  writefile <- paste0(outputdir, viewname, ".json")
  # writefile <- paste0(outputdir, "diagramLayouts2.json")
  
  parsedjson <- fromJSON(df_keys$diagramLayouttext)
  
  diagramLayoutjson <- parsedjson
  
  # Generate diagramLayouts.json
  write_json(diagramLayoutjson, writefile, pretty = TRUE, auto_unbox = TRUE)
  
  # for oml-vision 0.2.6
  text_instance <- read_file(writefile)
  text_instance <- paste0("{\n", "\"", viewname, "\": ", text_instance, "}\n")
  cat(file=writefile, text_instance)
  
  ###############################################################################
  # page.jsonを読み込んで、pathが存在しなかったら追加する処理が欲しい。
  
  outputdir <- paste0(omlrepo,"src/vision/viewpoints/")
  readfile <- paste0(outputdir, "pages.json")
  # writefile <- paste0(outputdir, "diagramLayouts2.json")
  writefile <- readfile
  
  pagesJson <- read_json(readfile)
  
  index <- NA
  for(i in 1:length(pagesJson[[2]]$children)){
    if( pagesJson[[2]]$children[[i]]$path == viewname){
      # Nothing to do, you already have a page
      index <- i
    }
  }
  if(is.na(index)){
    index <- i + 1
  }
  pagesJson[[2]]$children[index][[1]]$title <- title
  pagesJson[[2]]$children[index][[1]]$type <- "diagram"
  pagesJson[[2]]$children[index][[1]]$path <- viewname
  
  
  write_json(pagesJson, writefile, pretty = TRUE, auto_unbox = TRUE)
  
  
  return(df_keys)
}
