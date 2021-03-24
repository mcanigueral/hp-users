
# Power-current conversion -----------------------------------------------

power_from_current <- function(current, n_phases) {
  ifelse(n_phases == 1, 240, sqrt(3)*400)*current
}
