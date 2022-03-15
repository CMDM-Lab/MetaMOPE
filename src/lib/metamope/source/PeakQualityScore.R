getPeakQualityScore <- function(all_AsFs, peak_quality_score_file) {
  mobile_phase_n <- ncol(all_AsFs)
  
  ## detected peaks
  detected_n <- apply(all_AsFs, 2, function(x) sum(!is.na(x)))
  detected_n_order <- order(detected_n)
  score_detected_peaks <- vector(mode="numeric", length=mobile_phase_n)
  index <- detected_n_order[1]
  score_detected_peaks[index] <- 1
  cnt <- 1
  for (i in 2:mobile_phase_n) {
    index <- detected_n_order[i]
    prev_index <- detected_n_order[i-1]
    if (detected_n[index] == detected_n[prev_index]) {
      score_detected_peaks[index] <- cnt
    }
    else {
      cnt = cnt + 1
      score_detected_peaks[index] <- cnt
    }
  }
  
  ## asymmetry factor of commonly detected analytes
  common_AsFs <- na.omit(all_AsFs)
  common_n <- nrow(common_AsFs)
  mean_AsFs <- colMeans(common_AsFs)
  sd_AsFs <- apply(common_AsFs, 2, sd)
  mean_AsFs_order <- order(mean_AsFs, decreasing = TRUE)
  common_AsFs_list <- c(common_AsFs[, mean_AsFs_order])
  grouping <- factor(rep(1:mobile_phase_n, each=common_n))
  common_AsFs_data <- data.frame(common_AsFs_list, grouping)
  result <- pairwise.t.test(common_AsFs_list, grouping, p.adjust.methods="holm")
  score_AsFs <- vector(mode="numeric", length=mobile_phase_n)
  index <- mean_AsFs_order[1]
  score_AsFs[index] <- 1
  cnt <- 1
  for (i in 2:mobile_phase_n) {
    index <- mean_AsFs_order[i]
    if (is.na(result$p.value[as.character(i), as.character(i-1)])){
      score_AsFs[index] <- cnt
    }
    else if (result$p.value[as.character(i), as.character(i-1)] > 0.05) {
      score_AsFs[index] <- cnt
    }
    else {
      cnt = cnt + 1
      score_AsFs[index] <- cnt
    }
  }
  
  ## write peak qaulity score table
  df <- data.frame(mobile_phase=colnames(all_AsFs),
                   detected_peaks_amount=detected_n,
                   common_asymmetry_factors_mean=mean_AsFs, 
                   common_asymmetry_factors_sd=sd_AsFs,
                   score_detected_peaks=score_detected_peaks, 
                   score_asymmetry_factor=score_AsFs, 
                   peak_quality_score=score_detected_peaks+score_AsFs)
  write.csv(df, peak_quality_score_file)
}