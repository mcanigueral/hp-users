library(auth0)
library(shiny)
library(dygraphs)
library(dutils)
library(reticulate)
library(dplyr)
library(lubridate)
library(purrr)
library(tidyr)
options(scipen=999) # To avoid scientific notation

# shiny::runApp(port = 8080, launch.browser = TRUE)


a0_info <- auth0::auth0_info()

# Python configuration
config <- config::get(file = 'config.yml')
reticulate::use_python(config$python_path, required = T) # Restart R session to change the python env


# Utils before running the app --------------------------------------------
source("support/server_utils.R")
source("support/ui_utils.R")
# source("support/downloadDataModule.R")


# Metadata ---------------------------------------------------------------
users_metadata <- readxl::read_xlsx('metadata.xlsx')


# Database import --------------------------------------------------
dynamodb <- get_dynamodb(
  aws_access_key_id = config$dynamodb$access_key_id,
  aws_secret_access_key = config$dynamodb$secret_access_key,
  region_name = config$dynamodb$region_name
)
power_dynamodb_table <- get_dynamo_table(dynamodb, config$dynamodb$power_table_name)
dht_dynamodb_table <- get_dynamo_table(dynamodb, config$dynamodb$dht_table_name)

