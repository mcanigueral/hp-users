
# Parse items from DynamoDB -----------------------------------------------

parse_item <- function(item) {
  tibble(
    id = item$id$S,
    datetime = as_datetime(as.numeric(item$timestamp$N)/1000, tz = config$tzone) %>% floor_date("5 minutes"),
    map_df(item$data$M, ~ .x$N) %>% mutate_all(as.numeric)
  )
}


# Power-current conversion -----------------------------------------------

power_from_current <- function(current, n_phases) {
  ifelse(n_phases == 1, 240, sqrt(3)*400)*current
}


# Peak hours --------------------------------------------------------------

get_peak_hours <- function(data) {
  summermonths <- 4:10
  summer_peak_hours <- 13:23
  winter_peak_hours <- 12:22
  
  data %>%
    mutate(
      peak = ifelse(
        ((month(datetime) %in% summermonths) & (hour(datetime) %in% summer_peak_hours)) |
          (!(month(datetime) %in% summermonths) & (hour(datetime) %in% winter_peak_hours)), TRUE, FALSE
      )
    )
}