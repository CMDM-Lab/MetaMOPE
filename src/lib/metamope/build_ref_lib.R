#setwd("~/Desktop/project/xcms/building_reference_library/")
#options(stringsAsFactors=FALSE)
.libPaths(c("/usr/local/lib/R/site-library", "/usr/lib/R/site-library", "/usr/lib/R/library"))

input.arg = commandArgs(TRUE)
working_dir = input.arg[1]
inj_order_file = input.arg[2]
standard_file = input.arg[3]
mzXML_files_url = input.arg[4]
win_size = input.arg[5]
mcq_threshold = input.arg[6]
#mcq_threshold = ifelse(input.arg[6] == 'NA', 0.9, as.numeric(input.arg[6]))
intensity_threshold = input.arg[7]
#intensity_threshold = ifelse(input.arg[7] == 'NA', 1000, as.numeric(input.arg[7]))
std_blk_threshold = input.arg[8]
#std_blk_threshold = ifelse(input.arg[8] == 'NA', 6, as.numeric(input.arg[8]))
rt_rsd_threshold = input.arg[9]
#rt_rsd_threshold = ifelse(input.arg[9] == 'NA', 15, as.numeric(input.arg[9]))
#need adjustment to deal with the one with no assigned parameters and use the default value as line 36~38

setwd(working_dir)
options(stringsAsFactors=FALSE)

## library
library(xcms)
library(baseline)
#library(prospectr)

## source files
#source("./source/EIC.R")
#source("./source/CODA.R")
#source("./source/Spectrum.R")
#source("./source/Jaggedness.R")
#source("./source/AsymmetryFactor.R")
#source("./source/FWHM.R")
#source("./source/Modality.R")
source("../../../../lib/metamope/source/EIC.R")
source("../../../../lib/metamope/source/CODA.R")
source("../../../../lib/metamope/source/Spectrum.R")
source("../../../../lib/metamope/source/Jaggedness.R")
source("../../../../lib/metamope/source/AsymmetryFactor.R")
source("../../../../lib/metamope/source/FWHM.R")
source("../../../../lib/metamope/source/Modality.R")

## Repo
#A190_repo <- "/Volumes/cmdm/dong-ming-tsai/CAPD/dong-ming-dialysis-hilic/A-190"
#batch_repo <- "/001/20140114_A-190_pos_batch01"
#in_repo <- paste0(A190_repo, batch_repo)
#out_repo <- paste0("./new_data", batch_repo)
mzXML_files <- c()
for (file in list.files(mzXML_files_url)){
  mzXML_files <- append(mzXML_files, paste0(mzXML_files_url, file))
}
#in_repo <- mzXML_files
out_repo <- paste0(working_dir, "/result") 
# dir.create(out_repo)
# dir.create(paste0(out_repo, "/EIC"))

##  Injection order
#inj_order_file <- paste0(in_repo, "/20140114_A-190_pos_batch01.csv")
# inj_order_file <- "/Volumes/cmdm/dong-ming-tsai/CAPD/dong-ming-dialysis-hilic/A-190/002/20140123_A-190_neg_batch04/20140123_A-190_neg_batch04.csv"
inj_order_raw <- read.csv(inj_order_file)
inj_order <- inj_order_raw
#inj_order$FileName <- sapply(inj_order$FileName, function(x) sub("\\.d", "\\.mzXML", x))
inj_order$Blk <- sapply(inj_order$FileName, function(x) grepl("BK", x))
inj_order_test <- inj_order

## Standards
#standards_file <- "./HILIC_library/algo_CODA90_pos_A190.csv"
# standards_file <- "./HILIC_library/stdlib_HILIC_v5.csv"
standards_raw <- read.csv(standard_file)
## ./HILIC_library/algo_CODA90_pos_A190.csv invalid name
#standards_raw$analyte[58] <- "pos_seq119_C0598_TG_mz555.462"
#standards_raw$analyte[229] <- "pos_seq451_C0619_PC_mz734.569"
#standards_raw$analyte[239] <- "pos_seq470_C0620_PS_mz736.512"
## ./HILIC_library/algo_CODA90_neg_A190.csv invalid name
# standards_raw$analyte[177] <- "neg_seq470_C0620_PS_mz734.498"
#standards_raw$Name <- sapply(standards_raw$analyte, function(x) unlist(strsplit(x, "_"))[4])
#standards_raw$mz <- sapply(standards_raw$analyte, function(x) as.numeric(unlist(strsplit(x, "mz"))[2]))
# standards_raw$Name <- standards$Compound.Name

## Mapping
#mapping_file <- "./HILIC_library/A-190_001_MappingTable.csv"
#mapping_raw <- read.csv(mapping_file)

## Build reference library
mcq_threshold <- 0.9
peak_int_threshold <- 1000
std_blk_threshold <- 6
rt_rsd_threshold <- 15
sample_n <- nrow(inj_order_test)
s <- 1
t0 <- Sys.time()
while (s <= sample_n) {
  ## Blk
  if (inj_order_test$Blk[s]) {
    #blk_file <- paste0(in_repo, inj_order_test$FileName[s])
    blk_file <- mzXML_files[inj_order_test$InjectionOrder]
    blk_raw_data <- readMSData(blk_file, mode="onDisk")
    s <- s + 1
    next
  }
  
  ## 3 repeats
  #mzXML_file <- inj_order_test$FileName[s:(s+2)]
  #mzXML_file <- sapply(mzXML_file, function(x) paste0(in_repo, "/mzXML/", x))
  rep_n <- length(mzXML_files)
  sample_name <- grep("S0..", unlist(strsplit(inj_order_test$FileName[s], "_")), value=TRUE)
  # sample_rows <- grep(sample_name, standards_raw$mix)
  #mix_name <- mapping_raw$Sample_ID[grep(sample_name, mapping_raw$Mapping_ID)]
  #mix_name <- grep("Mix0..", unlist(strsplit(mix_name, " ")), value=TRUE)
  #mix_name <- sub("Mix0", "N", mix_name)
  # mix_name <- sub("Mix", "S", mix_name)
  #sample_rows <- grep(mix_name, standards_raw$mix)
  # sample_rows <- grep(mix_name, standards_raw$remix)
  standards <- standards_raw$Compound
  standards_n <- length(standards)
  ion_mode <- "pos"
  s <- s + 3
  
  if (standards_n == 0) {
    print(paste(sample_name, "no standard"))
    next
  }
  # library(xcms)
  # source("./source/EIC.R")
  # source("./source/CODA.R")
  # source("./source/Spectrum.R")
  mcq <- rt <- peak_int <- std_blk <- matrix(0, nrow = standards_n, ncol = rep_n)
  jaggedness <- asyFactor <- fwhm <- modality <- matrix(0, nrow = standards_n, ncol = rep_n)
  rt_rsd <- vector(mode="numeric", length=standards_n)
  for (r in 1:rep_n) {
    blk_raw_data <- readMSData(blk_file, mode="onDisk")
    raw_data <- readMSData(mzXML_files[r], mode="onDisk")  
    for (k in 1:standards_n) {
      ## EIC
      # source("./source/EIC.R")
      # mz_k <- switch(ion_mode, 
      #                pos=standards[k, ]$modifiedMass+1.00784,
      #                neg=standards[k, ]$modifiedMass-1.00784)
      # mz_k <- switch(ion_mode,
      #                pos=standards[k, ]$mzpos,
      #                neg=standards[k, ]$mzneg)
      mz_k <- standards_raw$mz[k]
      eics <- getEICs(raw_data=raw_data, mz=mz_k, ppm_tolerance=10)
      eic_1 <- eics[1, 1]
      blk_eics <- getEICs(raw_data=blk_raw_data, mz=mz_k, ppm_tolerance=10)
      blk_eic_1 <- blk_eics[1, 1]
      
      ## MCQ
      # source("./source/CODA.R")
      mcq[k, r] <- getMCQ(eic_1, win_size=3)
      
      ## Spectrum
      # source("./source/Spectrum.R")
      spectrum_k <- getSpectrum(eic_1)
      blk_spectrum_k <- getSpectrum(blk_eic_1)
      
      ## IRLS baseline correction (bc)
      # library(baseline)
      bc <- baseline::baseline(spectrum_k, method='irls')
      bc_spectrum <- getCorrected(bc)
      # blk_bc <- baseline(blk_spectrum_k, method='irls')
      # blk_bc_spectrum <- getCorrected(blk_bc)
      
      ## Savitzky-Golay (sg) smoothing filter
      library(prospectr)
      sg_spectrum <- savitzkyGolay(bc_spectrum, m=0, p=3, w=11, delta.wav=2)
      # blk_sg_spectrum <- savitzkyGolay(blk_bc_spectrum, m=0, p=3, w=11, delta.wav=2)
      
      ## peak intensity
      scan_index <- which.max(sg_spectrum)
      peak_int[k, r] <- sg_spectrum[scan_index]
      
      ## rt
      rt[k, r] <- rtime(eic_1)[scan_index]
      
      ## std/blk
      # std_blk[k, r] <- sg_spectrum[scan_index] / blk_sg_spectrum[scan_index]
      std_blk[k, r] <- sg_spectrum[scan_index] / blk_spectrum_k[scan_index]
      
      ## jaggedness
      # source("../source/Jaggedness.R")
      jaggedness[k, r] <- getJaggedness(sg_spectrum) 

      ## asymmetry factor
      # source("../source/AsymmetryFactor.R")
      asyFactor[k, r] <- getAsymmetryFactor(sg_spectrum)
      
      ## FWHM
      # source("../source/FWHM.R")
      fwhm[k, r] <- getFWHM(sg_spectrum)
      
      ## modality
      # source("../source/Modality.R")
      modality[k, r] <- getModality(sg_spectrum)
      
      ## plot EIC
      # file_eic <- paste0(out_repo, "/EIC/", sample_name, "_", r, "_", standards[k,]$Name, "_eic.png")
      # png(file_eic, width = 640, height = 480, units = "px")
      # rtr <- c(rt[k, r]-50, rt[k, r]+50)
      # plot(eics, rt=rtr, main=standards[k, ]$Name)
      # dev.off()
    }
  }
  
  ## rt_rsd
  rt_rsd <- apply(rt, 1, function(x) sd(x)/mean(x)*100)
  
  ## Validation
  mcq_validation <- apply(mcq, 1, function(x) median(x) > mcq_threshold)
  peak_int_validation <- apply(peak_int, 1, function(x) median(x) > peak_int_threshold)
  std_blk_validation <- apply(std_blk, 1, function(x) median(x) > std_blk_threshold)
  rt_rsd_validation <- (rt_rsd < rt_rsd_threshold)
  validation <- mcq_validation & peak_int_validation & rt_rsd_validation & std_blk_validation
  
  ## Write results
  all_results <- data.frame(
    # compund = standards$Compound.Name,
    compound = standards,
    mcq_1st = round(mcq[ , 1],3),
    mcq_2nd = round(mcq[ , 2],3),
    mcq_3rd = round(mcq[ , 3],3),
    rt_1st = rt[ , 1],
    rt_2nd = rt[ , 2],
    rt_3rd = rt[ , 3],
    std_blk_1st = round(std_blk[ , 1],3),
    std_blk_2nd = round(std_blk[ , 2],3),
    std_blk_3rd = round(std_blk[ , 3],3),
    peak_intensity_1st = round(peak_int[ , 1],3),
    peak_intensity_2nd = round(peak_int[ , 2],3),
    peak_intensity_3rd = round(peak_int[ , 3],3),
    rt_rsd = round(rt_rsd,3),
    jaggedness_1st = round(jaggedness[, 1],3),
    jaggedness_2nd = round(jaggedness[, 2],3),
    jaggedness_3rd = round(jaggedness[, 3],3),
    asymmetry_factor_1st = round(asyFactor[ ,1],3),
    asymmetry_factor_2nd = round(asyFactor[ ,2],3),
    asymmetry_factor_3rd = round(asyFactor[ ,3],3),
    FWHM_1st = round(fwhm[, 1],3),
    FWHM_2nd = round(fwhm[, 2],3),
    FWHM_3rd = round(fwhm[, 3],3),
    modality_1st = round(modality[, 1],3),
    modality_2nd = round(modality[, 2],3),
    modality_3rd = round(modality[, 3],3),
    validation = validation
  )
  #all_results_out_file <- paste0(out_repo, "/", sample_name, "_ref_lib_all_results.csv")
  all_results_out_file <- paste0(out_repo, "/ref_lib_all_results.csv")
  write.csv(all_results, all_results_out_file)
  
  ## Reference library table
  # ref_lib <- data.frame(
  #   # compund = standards$Compound.Name,
  #   compund = standards$Name[validation],
  #   # mzpos = standards$mzpos[validation],
  #   # mzneg = standards$mzneg[validation],
  #   # modifiedMass = standards$modifiedMass[validation], 
  #   mz = standards$mz[validation],
  #   rt = apply(rt, 1, median)[validation],
  #   peak_int = apply(peak_int, 1, median)[validation]
  # )
  # ref_lib_out_file <- paste0(out_repo, "/", sample_name, "_ref_lib.csv")
  # write.csv(ref_lib, ref_lib_out_file)
  
  t <- Sys.time()
  print(paste(sample_name, "done at", (t-t0), "min"))
}


