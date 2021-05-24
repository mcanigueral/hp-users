auth0_ui(dashboardPage(
  title = "Aerotèrmia", skin = "green",
  dashboardHeader(title = "Monitorització d'aerotèrmia",
                  titleWidth = 300,
                  tags$li(
                    logoutButton("", icon = icon('sign-out'), style = "border-radius: 10px;"),
                    class = "dropdown", 
                    style = "margin-top:5px; margin-right:10px;"
                  )
  ),
  dashboardSidebar(disable = T),
  dashboardBody(
    use_waiter(),
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "infobox.css")
    ),
    # Menu
    uiOutput("menu"),
    # Body
    uiOutput("graph"),
    uiOutput("indicators"),
    hr(),
    # Download data
    downloadButton("download", "Descarrega't les dades (Excel)")
  )
), info = a0_info)