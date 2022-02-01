## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----libraries, message=FALSE-------------------------------------------------
library(readr)
library(tidyverse)
library(hlaR)

## -----------------------------------------------------------------------------
tx_cohort_clean <- read.csv(system.file("extdata/example", "Haplotype_test.csv", package = "hlaR"))

## ---- results='hide', fig.keep='all'------------------------------------------
haplotbl<- ImputeHaplo(tx_cohort_clean)

## -----------------------------------------------------------------------------
# imputehires <- slice (haplotbl)
#write_csv(imputehires, "tx_cohort_imputed")

