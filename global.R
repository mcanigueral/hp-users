library(auth0)
library(shiny)
library(shinydashboard)
library(dygraphs)
library(dutils)
library(dplyr)
library(lubridate)
library(purrr)
library(tidyr)
library(paws)
library(waiter)
options(scipen=999) # To avoid scientific notation

# shiny::runApp(port = 8080, launch.browser = TRUE)


a0_info <- auth0::auth0_info()

# Python configuration
config <- config::get(file = 'config.yml')


# Python environment ------------------------------------------------------
reticulate::use_python(config$python_path, required = T) # Restart R session to change the python env
boto3 <- reticulate::import("boto3")


# Utils before running the app --------------------------------------------
source("support/server_utils.R")
source("support/ui_utils.R")

# Metadata ---------------------------------------------------------------
users_metadata <- readxl::read_xlsx('metadata.xlsx')


# Database import --------------------------------------------------
sensors_dynamodb <- get_dynamodb_py(
  aws_access_key_id = config$dynamodb$access_key_id,
  aws_secret_access_key = config$dynamodb$secret_access_key,
  region_name = config$dynamodb$region_name
)
power_table <- get_dynamo_table_py(sensors_dynamodb, config$dynamodb$power_table_name)
dht_table <- get_dynamo_table_py(sensors_dynamodb, config$dynamodb$dht_table_name)

# # Test to get data from specific user -------------------------------------
# rs <- query_timeseries_data_table_py(
#   power_table, 'id', '9479', 'timestamp', 
#   today()-days(1), today()+days(1)
# ) %>% 
#   mutate(
#     datetime = floor_date(as_datetime(timestamp/1000, tz = config$tzone), '5 minutes'),
#     map_dfr(data, ~ .x)
#   ) %>% 
#   power_from_current(n_phases = 1) %>% 
#   select(id, datetime, power)

