## library
.libPaths(c("/usr/local/lib/R/site-library", "/usr/lib/R/site-library", "/usr/lib/R/library"))

library(xcms)
library(baseline)
#library(prospectr)

## source files
#source("./source/EIC.R")
#source("./source/CODA.R")
#source("./source/Spectrum.R")
#source("./source/AsymmetryFactor.R")
source("../../../../lib/metamope/source/EIC.R")
source("../../../../lib/metamope/source/CODA.R")
source("../../../../lib/metamope/source/Spectrum.R")
source("../../../../lib/metamope/source/AsymmetryFactor.R")

getPeakInformation <- function(standards, mzXML_file, peak_information_file, mcq_threshold=0.9, 
                               intensity_threshold=5000, EIC_ppm_tolerance=10, MCQ_win_size=5) {
  # library(xcms)
  raw_data <- readMSData(mzXML_file, mode="onDisk")
  n <- nrow(standards)
  mcqs <- vector(mode="numeric", length=n)
  max_intensities <- vector(mode="numeric", length=n)
  AsFs <- rep(NA, n)
  for (k in 1:n) {
    ## EIC
    # source("./source/EIC.R")
    mz_k <- standards[k, ]$mz
    eics <- getEICs(raw_data, mz_k, ppm_tolerance=EIC_ppm_tolerance)
    eic_1 <- eics[1, 1]
    
    ## MCQ and local maximum
    # source("./source/CODA.R")
    mcqs[k] <- getMCQ(eic_1, win_size=MCQ_win_size)
    max_index <- which.max(intensity(eic_1))
    max_intensities[k] <- intensity(eic_1)[max_index]
    
    if (mcqs[k] < mcq_threshold | max_intensities[k] < intensity_threshold) {
      next
    }
    
    ## Spectrum
    # source("./source/Spectrum.R")
    spectrum_k <- getSpectrum(eic_1)
    
    ## IRLS baseline correction (bc)
    # library(baseline)
    bc <- baseline::baseline(spectrum_k, method='irls')
    bc_spectrum <- getCorrected(bc)
    
    ## Savitzky-Golay (sg) smoothing filter
    library(prospectr)
    sg_spectrum <- savitzkyGolay(bc_spectrum, m=0, p=3, w=11, delta.wav=2)
    
    ## Asymmetry factor
    # source("./source/AsymmetryFactor.R")
    AsFs[k] <- getAsymmetryFactor(sg_spectrum)
  }
  
  ## write peak information
  df <- data.frame(Compound=standards$Compound,
                   MCQ=mcqs,
                   peak_intensity=max_intensities,
                   asymmetry_factor=AsFs)
  write.csv(df, peak_information_file)
}