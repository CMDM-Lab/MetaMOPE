getJaggedness <- function(sg_spectrum, flatness_factor=0.05) {
  diff_intensity <- diff(sg_spectrum[1, ])
  
  ## near-flat ranges of peak
  near_flat_peaks <- which(abs(diff_intensity) < flatness_factor * max(abs(sg_spectrum[1, ])))
  diff_intensity[near_flat_peaks] <- 0
  
  ## jaggedness
  diff_direction <- diff(sign(diff_intensity))
  jaggedness <- (sum(abs(diff_direction) > 1) - 1)/(length(diff_direction) - 1)
  jaggedness <- max(0, jaggedness)
  return(jaggedness)
}