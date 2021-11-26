getMCQ <- function(eic, win_size=5) {
  intensity_raw <- intensity(eic)
  scan_n <- length(intensity_raw)
  reduced_n <- scan_n - win_size + 1
  
  ## length-scaled MS
  len <- sqrt(sum(intensity_raw ^ 2))
  intensity_scaled <- intensity_raw / len
  
  ## smoothed MS
  intensity_smoothed <- vector()
  for (i in 1:reduced_n) {
    smoothed_value <- mean(intensity_raw[i:(i+win_size-1)])
    intensity_smoothed <- c(intensity_smoothed, smoothed_value)
  }
  
  ## smoothed standardized (ss) MS
  u <- mean(intensity_smoothed)
  s <- sd(intensity_smoothed)
  intensity_ss <- (intensity_smoothed - u) / s
  
  ## MCQ
  mcq <- sum(intensity_scaled[1:reduced_n] * intensity_ss) / sqrt(scan_n-win_size)
  return(mcq)
}
