library(tidyverse)

# Function to create tree diagram

library(collapsibleTree)
library(colorspace)
library(jsonlite)
library(DT)


###############################################################################
# Reusable Functions
searchDirectory <- function(iteration, pattern, parent_directory){
  for(i in 1:iteration){
    path <- list.files(parent_directory, recursive = TRUE, pattern = pattern, full.names = TRUE)
    if(length(path)){
      return(path)
    }
    parent_directory <- dirname(parent_directory)
  }
  print("file not found")
  return(path)
}

# set path to oml model 
path <- searchDirectory(4, "build.gradle", (getwd()))
omlrepo <- stringr::str_split(path, "build.gradle", simplify = TRUE)[1]



###############################################################################
#' readQueryResultsFromJson
#'
#' @param filepath path to json file
#'
#' @return df convert json to data frame 
#' 
readQueryResultsFromJson <- function(filepath){
  jsondata <- jsonlite::fromJSON(filepath)
  
  colnum <- ncol(jsondata$results$bindings)
  df <- data.frame(matrix(rep(NA, colnum), nrow=1))[numeric(0), ]
  colnames(df) <- c(names(jsondata$results$bindings))
  
  for (i in 1:nrow(jsondata$results$bindings)) {
    for (j in 1:colnum) {
      df[i,j] <- jsondata$results$bindings[i,j]$value
    }
  }
  return(df)
}

###############################################################################
#' plotCollapsibleTreeFromDataframe
#'
#' @param df 
#' @param palette 
#' @param parent 
#' @param child
#' @param types
#'
plotCollapsibleTreeFromDataframe <- function(df, 
                                             palette="BluYl", 
                                             parent="c2_name", 
                                             child="c1_name",
                                             types="c1_type",
                                             tooltips){
  # parent(owner), child(name)の順で列を構成する必要がある。
  df_tree <- df %>%
    mutate(owner=df[[parent]]) %>%
    mutate(name=df[[child]]) %>%
    mutate(type=df[[types]]) %>%
    select(owner, name, type) %>%
    arrange(desc(owner))
  
  # Generate color table
  look <- data.frame(
    item =  unique(df_tree$type),
    colorcode = colorspace::sequential_hcl(length(unique(df_tree$type)), palette)
  )
  df_tree <-df_tree %>%
    mutate(color = look$colorcode[match(unlist(df_tree$type), look$item)])
  
  
  if(!is.null(df_tree[["tooltip"]])){
    df_tree <- df_tree %>%
      mutate(tooltip=df[[tooltips]])
    collapsibleTree::collapsibleTreeNetwork(df_tree, fill="color", collapsed = FALSE, tooltipHtml = "tooltip")
  }else{
    collapsibleTree::collapsibleTreeNetwork(df_tree, fill="color", collapsed = FALSE)
  }
  # node <- data.tree::FromDataFrameNetwork(df)
}  


