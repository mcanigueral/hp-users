
# Download data module ---------------------------------------------------------
# This module lets the user to download a dataset in Excel or CSV, 
# filtering the column "id" according to the selected boxes

# UI
plotIDDataUI <- function(id, options, label=NULL){
  ns <- NS(id)
  tagList(
    fluidRow(box(
      checkboxGroupInput(
        ns('selected'), 
        label,
        choices = set_names(options, options),
        selected = options,
        inline = TRUE
      )
    )),
    fluidRow(
      uiOutput(ns('plot_list'))
    )
  )
}


plotIDDataServer <- function(id, data, date_range) {
  moduleServer(
    id,
    function(input, output, session) {

      selected_ids <- reactive(input[['selected']])

      output[['plot_list']] <- renderUI({
        map(
          selected_ids(),
          ~ box(width = 12,
            h3(strong(.x), align = "center"),
            renderDygraph({
              data %>% 
                filter(id == .x) %>% 
                select(-id) %>% 
                filter(between(date(datetime), date_range()[1], date_range()[2])) %>% 
                plot_user_data(.x) # Final plot function adapted to every case
            })
          )
        )
      })
    }
  )
}


