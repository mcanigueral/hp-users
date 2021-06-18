auth0_server(function(input, output, session) {

  user_metadata <- reactive({
    users_metadata %>% 
      filter(mail == session$userData$auth0_info$name) %>% 
      as.list()
  })
  
  output$menu <- renderUI({
    req(session$userData$auth0_info)
    tagList(
      fluidRow(column(3,
        dateRangeInput("dates", "Selecciona el període a visualitzar:",
                       start = today() - days(1), end = today(),
                       min = dmy(01012020), max = today(),
                       language = "ca", weekstart = 1)
      ))
      # hr()
    )
  })
  
  power_data <- reactive({
    req(input$dates)
    waiter_show(html = waiting_screen("Consultant el consum elèctric..."), color = "#00000080")
    current_tbl <- query_timeseries_data_table_py(
      power_table, 'id', user_metadata()$id_power, 'timestamp', input$dates[1], input$dates[2]+days(1)
    )
    waiter_hide()
    if (!is.null(current_tbl)) {
      return( 
        current_tbl %>% 
          mutate(
            datetime = floor_date(as_datetime(timestamp/1000, tz = config$tzone), '5 minutes'),
            map_dfr(data, ~ .x),
            power = power_from_current(current, user_metadata()$phases)
          ) %>% 
          select(datetime, power)
      )
    } else {
      return(tibble(datetime = input$dates[1], power = NA))
    }
  })
  
  dht_data <- reactive({
    req(input$dates)
    waiter_show(html = waiting_screen("Consultant la temperatura..."), color = "#00000080")
    dht_tbl <- query_timeseries_data_table_py(
      dht_table, 'id', user_metadata()$id_dht, 'timestamp', input$dates[1], input$dates[2]+days(1)
    )
    waiter_hide()
    if (!is.null(dht_tbl)) {
      return( 
        dht_tbl %>% 
          mutate(
            datetime = floor_date(as_datetime(timestamp/1000, tz = config$tzone), '5 minutes'),
            map_dfr(data, ~ .x)
          ) %>% 
          select(datetime, temperature)
      )
    } else {
      return(tibble(datetime = input$dates[1], temperature = NA))
    }
  })
  
  indicators <- reactive({
    avg_power_day <- power_data() %>% 
      group_by(date = date(datetime)) %>% 
      summarise(demand = sum(power*5/60))
    avg_temperature_day <- dht_data() %>% 
      group_by(date = date(datetime)) %>% 
      summarise(avg_temp = mean(temperature))
    kpis <- list(
      avg_demand_day = mean(avg_power_day$demand)/1000,
      max_demand = max(power_data()$power, na.rm = T)/1000,
      max_demand_dttm = power_data()$datetime[which(max(power_data()$power, na.rm = T) == power_data()$power)][1],
      avg_temp_day = mean(avg_temperature_day$avg_temp, na.rm = T),
      min_temp = min(dht_data()$temperature, na.rm = T),
      max_temp = max(dht_data()$temperature, na.rm = T)
    )
    tagList(
      infoBox(
        "Consum mitjà diari", 
        ifelse(!is.na(kpis$avg_demand_day), round(kpis$avg_demand_day, 2), 0), 
        'kWh', NULL, 'plug', '#ccff99', 3
      ),
      infoBox(
        "Pic de consum", 
        ifelse(!is.infinite(kpis$max_demand), round(kpis$max_demand, 1), 0), 
        'kW', 
        kpis$max_demand_dttm, 
        'bolt', '#99ff99', 3
      ),
      infoBox(
        "Temperatura mitjana diària", 
        ifelse(!is.na(kpis$avg_temp_day), round(kpis$avg_temp_day, 1), 0), 'ºC', 
        NULL, 'thermometer-half', '#80ccff', 3
      ),
      infoBox(
        "Rang de temperatura mesurat", 
        paste(
          ifelse(!is.infinite(kpis$min_temp), round(kpis$min_temp, 1), 0), 
          '-', 
          ifelse(!is.infinite(kpis$max_temp), round(kpis$max_temp, 1), 0)
        ),
        'ºC', NULL, 'balance-scale-left', '#99c2ff', 3
      )
    )
  })
  
  user_data <- reactive({
    left_join(power_data(), dht_data(), by = 'datetime') %>% 
      fill(-datetime, .direction = "down") %>%
      arrange(datetime) %>% 
      distinct()
  }) 
  
  output$dyplot <- renderDygraph({
    user_data() %>% 
      dyplot() %>% 
      dySeries("power", label = "Consum elèctric", axis=('y'), color = "green", fillGraph = T) %>% 
      dyAxis("y", label = "Potència (W)", valueRange = c(0, max(user_data()[['power']], na.rm = T)*1.2)) %>% 
      dySeries("temperature", label = "Temperatura interior", axis=('y2'), color = "navy", strokeWidth = 2) %>% 
      dyAxis("y2", label = "Temperatura (ºC)", valueRange = c(0, max(user_data()[['temperature']], na.rm = T)*1.2)) %>% 
      dyRangeSelector()
  })
  
  
  output$graph <- renderUI({
    tagList(
      wellPanel(
        style = 'background: #fff; border-top: 3px solid #d2d6de;', 
        fluidRow(dygraphOutput('dyplot'))
      )
    )
  })
  
  output$indicators <- renderUI({
    fluidRow(
      align = 'center',
      indicators()
    )
  })
  
  output$download <- downloadHandler(
    filename = function() {
      paste0("aerotermia-", today(), ".xlsx")
    },
    content = function(file) {
      writexl::write_xlsx(user_data(), file)
    }
  )
  
  
}, info = a0_info)