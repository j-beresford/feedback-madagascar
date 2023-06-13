rm(list=ls())
library(httr)
library(jsonlite)
library(tidyverse)

api_key <- "4f55fc97-6141-41ea-8281-630ff9c7c3dc"



## Get tree loss data
url <- "https://data-api.globalforestwatch.org/dataset/umd_tree_cover_loss/latest/query"

headers <- c(
  "x-api-key" = api_key,
  "Content-Type" = "application/json"
)

body <- '{
  "geometry": {
    "type": "Polygon",
    "coordinates": [
      [
        [103.19732666015625, 0.5537709801264608],
        [103.24882507324219, 0.5647567848663363],
        [103.21277618408203, 0.5932511181408705],
        [103.19732666015625, 0.5537709801264608]
      ]
    ]
  },
  "sql": "SELECT SUM(area__ha) FROM results GROUP BY umd_tree_cover_loss__year"
}'

response <- POST(url, add_headers(headers), body = body)
content <- content(response, as = "text")
parsed_content <- fromJSON(content)

treatment_data <- parsed_content[['data']]


##### Control group data #####
body <- '{
  "geometry": {
    "type": "Polygon",
    "coordinates": [
      [
        [103.29732666015625, 0.4537709801264608],
        [103.34882507324219, 0.4647567848663363],
        [103.31277618408203, 0.4932511181408705],
        [103.29732666015625, 0.4537709801264608]
      ]
    ]
  },
  "sql": "SELECT SUM(area__ha) FROM results GROUP BY umd_tree_cover_loss__year"
}'

response <- POST(url, add_headers(headers), body = body)
content <- content(response, as = "text")
parsed_content <- fromJSON(content)
control_data <- parsed_content[['data']]


