
# Download data module ---------------------------------------------------------
# This module lets the user to download a dataset in Excel or CSV, 
# filtering the column "id" according to the selected boxes

# UI
downloadDataUI <- function(id, options, label=NULL){
  ns <- NS(id)
  fluidRow(box(
    width = 4,
    checkboxGroupInput(
      ns('selected'),
      label,
      choices = set_names(options, options),
      selected = options,
      inline = TRUE
    ),
    downloadButton(ns("download_xlsx"), "Excel"),
    downloadButton(ns("download_csv"), "CSV")
  ))
}

# Server
downloadDataServer <- function(id, data, date_range) {
  moduleServer(
    id,
    function(input, output, session) {
      
      selected_data <- reactive({
        data %>% 
          filter(id %in% input[['selected']]) %>%  
          filter(between(date(datetime), date_range()[1], date_range()[2]))
      })
      
      output$download_xlsx  <- download_button("xlsx", selected_data())
      output$download_csv  <- download_button("csv", selected_data())
    }
  )
}



# Support functions for the module -----------------------------------------

# Download button function
download_button <- function(fileext = c("csv", "csv2", "xlsx"), data) {
  
  if (fileext %in% c("csv", "csv2")) {
    filename <- paste0("heatpumps_", Sys.Date(), ".csv")
    if (fileext == "csv") writing_func <- write_csv
    if (fileext == "csv2") writing_func <- write_csv2
  } else if (fileext %in% c("xlsx")) {
    filename <- paste0("heatpumps_", Sys.Date(), ".xlsx")
    writing_func <- write_xlsx
  } else {
    message("File extension not valid.")
    return( NULL )
  }
  
  downloadHandler(
    filename = function() { filename },
    content = function(file) {
      writing_func(data, path = file)
    }
  )
}