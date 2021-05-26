auth0_ui(dashboardPage(
  title = "Aerotèrmia", skin = "green",
  dashboardHeader(title = tagList(tags$img(src = "udg_logo_short.png", height = "40px;"),
                                  HTML("&nbsp;"),
                                  "Monitorització d'aerotèrmia"),
                  titleWidth = 350,
                  tags$li(
                    logoutButton(
                      "Tanca sessió", icon = icon('sign-out'),
                      style = "border-radius: 10px; background-color: #008D4C; border-color: #008D4C; color: white;"
                    ),
                    class = "dropdown",
                    style = "margin-top:5px; margin-right:10px;"
                  )
  ),
  dashboardSidebar(
    disable = T
    # width = 350, collapsed = T,
    # logoutButton(
    #   "Tanca sessió", icon = icon('sign-out'),
    #   style = "border-radius: 10px; background-color: #008D4C; border-color: #008D4C; color: white;"
    # )
  ),
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
    downloadButton("download", "Descarrega't les dades (Excel)",
                   style = "border-radius: 10px; background-color: #008D4C; border-color: #008D4C; color: white;")
  )
), info = a0_info)