#working_dir <- "~/Desktop/project/xcms/mobile_phase_evaluation/"
#setwd(working_dir)
#options(stringsAsFactors=FALSE)
input.arg = commandArgs(TRUE)
working_dir = input.arg[1]
grouping_file = input.arg[2]
standard_file = input.arg[3]
mobile_phases = input.arg[4]
mzxml_files = input.arg[5]
MCQ_win_size = as.numeric(input.arg[6])
mcq_threshold = as.numeric(input.arg[7])
intensity_threshold = as.numeric(input.arg[8])
#need adjustment to deal with the one with no assigned parameters and use the default value as line 36~38

setwd(working_dir)

## library
# library(tidyverse)

## source files
# source("./source/PeakInformation.R")
# source("./source/PeakQualityScore.R")

## read information of standards
library(tidyverse)
#standards_file <- "./40StdQC.csv"
standards_raw <- read.csv(standards_file)
standards_pos <- standards_raw[standards_raw$Ion.Mode == "pos", ] %>% select(-neg_mz) %>% rename(mz=pos_mz)
standards_neg <- standards_raw[standards_raw$Ion.Mode == "neg", ] %>% select(-pos_mz) %>% rename(mz=neg_mz)

## peak information of a mobile phase
#mzXML_dir <- "./mzXML/"
peak_information_dir <- "./peak_information/"
#mobile_phases <- list.files(mzXML_dir)
mobile_phase_n <- length(mobile_phases)
EIC_ppm_tolerance <- matrix(0, mobile_phase_n, 2, dimnames=list(mobile_phases, c("pos", "neg")))
EIC_ppm_tolerance[1, 1:2] <- 10
EIC_ppm_tolerance[2, 1:2] <- 30
MCQ_win_size <- 3
mcq_threshold <- 0.9
intensity_threshold <- 5000

source("./source/PeakInformation.R")
#for (mobile_phase in mobile_phases) {
for (i in 1:mobile_phase_n){
  for (mode in c("pos", "neg")) {
    standards <- switch(mode, pos=standards_pos, neg=standards_neg)
    #mzXML_file <- list.files(paste0(mzXML_dir, mobile_phases[i]), pattern=paste0("*_", mode, "\\.mzXML"))
    mzXML_file <- list.mzxml_files(pattern=paste0("*_", mode, "\\.mzXML"))
    peak_information_file <- sub("\\.mzXML", "_peak_information.csv", mzXML_file)
    getPeakInformation(standards=standards,
                       #mzXML_file=paste0(mzXML_dir, mobile_phases[i], "/", mzXML_file),
                       mzXML_file=mzXML_file
                       peak_information_file=paste0(peak_information_dir, mobile_phases[i], "/", peak_information_file), 
                       mcq_threshold=mcq_threshold, 
                       intensity_threshold=intensity_threshold, 
                       EIC_ppm_tolerance=EIC_ppm_tolerance[mobile_phases[i], mode], 
                       MCQ_win_size=MCQ_win_size)
  }
}

## peak quality score table
standards_n <- nrow(standards_raw)
standards_pos_n <- nrow(standards_pos)
standards_neg_n <- nrow(standards_neg)
all_AsFs <- matrix(0, standards_n, mobile_phase_n)
colnames(all_AsFs) <- mobile_phases
for (i in 1:mobile_phase_n) {
  pos_file <- list.files(paste0(peak_information_dir, mobile_phases[i]), pattern="*_pos_peak_information.csv")
  pos_peak_information <- read.csv(paste0(peak_information_dir, mobile_phases[i], "/", pos_file))
  neg_file <- list.files(paste0(peak_information_dir, mobile_phases[i]), pattern="*_neg_peak_information.csv")
  neg_peak_information <- read.csv(paste0(peak_information_dir, mobile_phases[i], "/", neg_file))
  all_AsFs[1:standards_pos_n, i] <- pos_peak_information$asymmetry_factor
  all_AsFs[(standards_pos_n+1):standards_n, i] <- neg_peak_information$asymmetry_factor
}
source("./source/PeakQualityScore.R")
getPeakQualityScore(all_AsFs,peak_quality_score_file=paste0(peak_information_dir, "peak_quality_score_table.csv"))