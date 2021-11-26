getFWHM <- function(sg_spectrum) {
  max_index <- which.max(sg_spectrum)
  max_intensity <- sg_spectrum[max_index]
  scan_n <- length(sg_spectrum)
  right_index <- max_index
  left_index <- max_index
  
  while (left_index > 0) {
    if (sg_spectrum[left_index] < max_intensity/2) {
      intensity_range <- c(sg_spectrum[left_index], sg_spectrum[left_index+1])
      rt_range <- c(as.numeric(colnames(sg_spectrum)[left_index]), as.numeric(colnames(sg_spectrum)[left_index+1]))
      rt_left <- approx(x=intensity_range, y=rt_range, xout=max_intensity/2)$y
      break
    }
    left_index <- left_index - 1
  }
  while (right_index <= scan_n) {
    if (sg_spectrum[right_index] < max_intensity/2) {
      intensity_range <- c(sg_spectrum[right_index-1], sg_spectrum[right_index])
      rt_range <- c(as.numeric(colnames(sg_spectrum)[right_index-1]), as.numeric(colnames(sg_spectrum)[right_index]))
      rt_right <- approx(x=intensity_range, y=rt_range, xout=max_intensity/2)$y
      break
    }
    right_index <- right_index + 1
  }
  
  if (left_index <= 0 | right_index > scan_n) {
    return(NA)
  }
  fwhm <- rt_right - rt_left
  return(fwhm)
}