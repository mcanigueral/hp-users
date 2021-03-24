infoBox <- function(title, value, units, subtitle, fa_icon, color, width=3) {
  shiny::column(
    width,
    shiny::HTML(paste0(
      '<div class="info-box" style= background:', color, '>',
      '<span class="info-box-icon">', shiny::icon(fa_icon), '</span>',
      '<div class="info-box-content">',
      '<span class="info-box-text"><b>', title, '</b></span>',
      '<span class="info-box-number">', paste(value, units), '</span>',
      if (!is.null(subtitle)) '<p style="margin: 0;">', subtitle, '</p>',
      '</div>',
      '</div>'
    ))
  )
}