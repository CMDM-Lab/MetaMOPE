getModality <- function(sg_spectrum, flatness_factor=0.05) {
  diff_intensity <- diff(sg_spectrum[1, ])
  
  ## near-flat ranges of peak
  near_flat_peaks <- which(abs(diff_intensity) < flatness_factor * max(abs(sg_spectrum[1, ])))
  diff_intensity[near_flat_peaks] <- 0
  
  # first and last timepoint where the differential changes sign
  first_fall <- head(which(diff_intensity < 0), 1)
  last_rise <- tail(which(diff_intensity > 0), 1)
  if (length(first_fall) == 0) first_fall <- length(sg_spectrum[1, ]) + 1
  if (length(last_rise) == 0) last_rise <- -1
  
  ## modality
  modality <- ifelse(first_fall < last_rise, 
                     max(abs(diff_intensity[first_fall:last_rise])) / max(sg_spectrum[1, ]), 0)
  return(modality)
}