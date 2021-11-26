getAsymmetryFactor <- function(sg_spectrum){
  max_index <- which.max(sg_spectrum)
  max_intensity <- sg_spectrum[max_index]
  scan_n <- length(sg_spectrum)
  A_index <- max_index
  B_index <- max_index
  while (A_index > 0) {
    if (sg_spectrum[A_index] < 0.1 * max_intensity) {
      intensity_range <- c(sg_spectrum[A_index], sg_spectrum[A_index+1])
      rt_range <- c(as.numeric(colnames(sg_spectrum)[A_index]), as.numeric(colnames(sg_spectrum)[A_index+1]))
      A_rt <- approx(x=intensity_range, y=rt_range, xout=0.1*max_intensity)$y
      break
    }
    A_index <- A_index - 1
  }
  while (B_index <= scan_n) {
    if (sg_spectrum[B_index] < 0.1 * max_intensity) {
      intensity_range <- c(sg_spectrum[B_index-1], sg_spectrum[B_index])
      rt_range <- c(as.numeric(colnames(sg_spectrum)[B_index-1]), as.numeric(colnames(sg_spectrum)[B_index]))
      B_rt <- approx(x=intensity_range, y=rt_range, xout=0.1*max_intensity)$y
      break
    }
    B_index <- B_index + 1
  }
  C_rt <- as.numeric(colnames(sg_spectrum)[max_index])
  AsF <- (B_rt - C_rt) / (C_rt - A_rt)
  return(AsF)
}