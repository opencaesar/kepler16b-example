# Reusable wrapper functions for oml-vision
library(tidyverse)
library(jsonlite)
library(igraph)
library(jsonlite)
library(networkD3)

###############################################################################
massRollUp <- function(g, root, df_mass, namekey="c1_localname", masskey="c1_mass"){
  
  # Analysis: Mass Rollup By Depth-First Traversal
  order <- dfs(g, V(g)[root], order.out = TRUE)$order.out
  
  for (v in order){
    # print(V(g)[v])
    children <- neighbors(g, v, mode="out")
    if( length(children) > 0) {
      # add mass
      mass <- sum(df_mass[is.element(df_mass[[namekey]], names(children)), masskey])
      df_mass[df_mass[[namekey]] == names(V(g)[v]), masskey] <- mass
    }
  }

  return(df_mass)
}


###############################################################################

generateMassDescriptions <- function(df){

  df_in <- df

  text <- paste0("// Mass Instances\n")
  text_instance <- ""

  for (i in 1:nrow(df_in)){
    name <- df_in$name[i]
    type <- df_in$type[i]
    instance <- df_in$instancename[i]
    mass <- df_in$mass[i]
    text_instance <- paste0(text_instance,
                            "	instance ", instance, " : mass:MassMagnitude [\n",
                            "		vim4:hasDoubleNumber \"", mass,"\"^^xsd:double\n",
                            "		vim4:characterizes ", type, ":", name,"\n",
                            "	]\n"
    )
  }
  
  text <- paste0(text, text_instance)
  return(text)
}

###############################################################################
generateOmlMassDescriptions <- function(df_instance){
  
  ### assemly.omlのフレーム作成
  omldescriptions <-
    "description <http://opencaesar.io/open-source-rover/description/mass/masses#> as masses {
  	uses <http://www.w3.org/2001/XMLSchema#> as xsd
  	uses <http://bipm.org/jcgm/vim4#> as vim4
  	uses <http://opencaesar.io/open-source-rover/vocabulary/mass#> as mass
  	
  	extends <http://opencaesar.io/open-source-rover/description/structure/subsystems#> as subsystems
  	extends <http://opencaesar.io/open-source-rover/description/assembly/assembly#> as assembly
  
  "
  
  ### Mass Instances : OK
  instance <- generateMassDescriptions(df_instance)
  
  # cat(instance)
  omldescriptions <- paste0(omldescriptions, instance,"\n")
  
  omldescriptions <- paste0(omldescriptions,"\n}\n")
  
  return(omldescriptions)
}
