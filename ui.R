auth0_ui(fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "infobox.css")
  ),
  column(12,
    # Header
    uiOutput('header'),
    # Menu
    uiOutput("menu"),
    # Body
    uiOutput("body")
  )
  
), info = a0_info)