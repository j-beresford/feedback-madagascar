rm(list=ls())
library(httr)
library(jsonlite)
library(tidyverse)
library(plm)        
library(broom)

#### Set API parameters
api_key <- "4f55fc97-6141-41ea-8281-630ff9c7c3dc"
url <- "https://data-api.globalforestwatch.org/dataset/umd_tree_cover_loss/latest/query"
headers <- c(
  "x-api-key" = api_key,
  "Content-Type" = "application/json"
)


################
### Get data ###
################

## Treatment ##
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
treatment_data <- parsed_content[['data']]%>%
  mutate(group='treatment')

## Control ##
body <- '{
  "geometry": {
    "type": "Polygon",
    "coordinates": [
      [
        [48.36932639981467, -17.681685327509115],
        [48.36932639981467, -17.92955607376615],
        [48.870286545981486, -17.92955607376615],
        [148.870286545981486, -17.681685327509115],
        [48.36932639981467, -17.681685327509115]      ]
    ]
  },
  "sql": "SELECT SUM(area__ha) FROM results GROUP BY umd_tree_cover_loss__year"
}'

response <- POST(url, add_headers(headers), body = body)
content <- content(response, as = "text")
parsed_content <- fromJSON(content)
control_data <- parsed_content[['data']]%>%
  mutate(group='control')

### Clean and merge treatment and control ###
merged_data <- treatment_data%>%
  bind_rows(control_data)%>%
  rename(year=umd_tree_cover_loss__year, area=area__ha)%>%
  mutate(intervention=if_else(year>2005 & group=='treatment', 1, 0))%>%
  as_tibble()

#########################
##### DID analysis ######
#########################


### Convert the data into a indexed panel
pdata <- pdata.frame(merged_data, index = c("group" ,"year"))

### Run a fixed effects model
model <- plm(area ~ intervention, data = pdata, model = "within")

## Show model results
tidy(model)

