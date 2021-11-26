getEICs <- function(raw_data, mz, rtr=c(-Inf,Inf), ppm_tolerance=10) {
  d <- ppm_tolerance * mz / 1e6
  mzr <- c(mz-d, mz+d)
  eics <- chromatogram(raw_data, mz = mzr, rt=rtr, missing=0)
  return(eics)
}