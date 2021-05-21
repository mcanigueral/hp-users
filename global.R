library(auth0)
library(shiny)
library(dygraphs)
library(dutils)
library(dplyr)
library(lubridate)
library(purrr)
library(tidyr)
library(paws)
options(scipen=999) # To avoid scientific notation

# shiny::runApp(port = 8080, launch.browser = TRUE)


a0_info <- auth0::auth0_info()

# Python configuration
config <- config::get(file = 'config.yml')


# Utils before running the app --------------------------------------------
source("support/server_utils.R")
source("support/ui_utils.R")


# Metadata ---------------------------------------------------------------
users_metadata <- readxl::read_xlsx('metadata.xlsx')


# Database import --------------------------------------------------
sensors_dynamodb <- get_dynamodb(
  aws_access_key_id = config$dynamodb$access_key_id,
  aws_secret_access_key = config$dynamodb$secret_access_key,
  region_name = config$dynamodb$region_name
)


# # Test to get data from specific user -------------------------------------
# rs <- get_dynamodb_data(sensors_dynamodb, 
#                         config$dynamodb$power_table_name, 
#                         'id', '9479', 
#                         'timestamp', dutils:::date_to_timestamp(Sys.time()-days(1)), dutils:::date_to_timestamp(Sys.time()), 
#                         parse_item)

