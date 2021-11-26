getSpectrum <- function(eic){
  spectrum <- matrix(intensity(eic), nrow=1)
  colnames(spectrum) <- rtime(eic)
  return(spectrum)
}