## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ---- message = FALSE---------------------------------------------------------
library(hlaR)
library(tidyverse)
library(dplyr)

## ---- message = FALSE---------------------------------------------------------
# use the testing data in the library
dat_mhc1 <-  read.csv(system.file("extdata/example", "MHC_I_test.csv", package = "hlaR"), sep = ",", header = TRUE) 
re_mhc1 <- CalEpletMHCI(dat_mhc1)
re_mhc1_single <- re_mhc1$single_detail
re_mhc1_overall <- re_mhc1$overall_count

## ---- message = FALSE---------------------------------------------------------
# use the testing data in the library
dat_mhc2 <-  read.csv(system.file("extdata/example", "MHC_II_test.csv", package = "hlaR"), sep = ",", header = TRUE)
re_mhc2 <- CalEpletMHCII(dat_mhc2)
re_mhc2_single <- re_mhc2$single_detail
re_mhc2_overall <- re_mhc2$overall_count
re_mhc2_drdq_risk <- re_mhc2$dqdr_risk

## ----visualize mm-------------------------------------------------------------
hist(re_mhc1_overall$mm_cnt_tt)
hist(re_mhc2_overall$mm_cnt_tt)

mm_eplets <- strsplit(re_mhc1_single$mm_eplets, split = ",")
mm_eplets <- as.data.frame(matrix(as.factor(unlist(mm_eplets))))
colnames(mm_eplets) <- c("eplets")

count<- mm_eplets %>%
        group_by(eplets) %>%
        summarize(count=n())

count %>%
    arrange(desc(count)) %>%
    top_n(10) %>%
    ggplot(aes(eplets, count)) +
    geom_col()


