#' @name CleanAllele
#' @title Clean messy HLA typing data
#' @description This function takes raw messy HLA(Human Leukocyte Antigen) typing data as input. It removes inconsistent formatting and unnecessary symbols. If one of two alleles at a loci is NA, the locus is assumed to be homozygous.
#' @param var_1
#' HLA on allele 1.
#' @param var_2
#' HLA on allele 2.
#' @return
#' A data frame with 4 columns:
#' - `var_1`: raw messy input hla, identical with first input
#' - `var_2`: raw messy input hla, identical with second input
#' - `locus1_clean`: cleaned hla of var_1
#' - `locus2_clean`: cleaned hla of var_2
#' @export
#'
#' @import
#' tidyverse
#' utils
#' readr
#'
#' @examples
#' dat <-  read.csv(system.file("extdata/example", "HLA_Clean_test.csv", package = "hlaR"))
#' re <- CleanAllele(dat$recipient_a1, dat$recipient_a2)

CleanAllele <- function(var_1, var_2) {
    #* step 0: if allele suffixed with N/n (not to be expressed), then set it to blank
    var_1 <- ifelse(substr(var_1, nchar(var_1), nchar(var_1)) %in% c("N", "n"), "", var_1)
    var_2 <- ifelse(substr(var_2, nchar(var_2), nchar(var_2)) %in% c("N", "n"), "", var_2)

    #* step 1: some definitions *#
    # set to NA for some unidentifiable values
    vec_na <- c("0.796527778", "0.175", "1/1/00 11:12")

    # define left and right round brackets
    brkt_l <- c("\\(|\\{|\\[|\\<")
    brkt_r <- c("\\)|\\}|\\]|\\>")
    #* end of step 1*#

    #* step 2: body of cleaning *#
    # logical line
    # - 1. if string in vec_na then set to NA
    # - 2. remove white spaces around the string
    # - 3. if string contains only letters then set to NA
    # - 4. unify all brackets to round
    # - 5. remove everything between round brackets including brackets
    # - 6. remove **XXX pattern start with *(could be 0 time) end with X(at least 1 time)
    # - 7. if there are more than 1 colons, remove everything starting from 2nd colon: 131:01:00 -> 131:01  26:08:00 -> 26:08
    # - 8. remove all punctuation marks except ":"
    # - 9. remove if letter left
    # - 10. if low resolution and nchar = 1 then paste a leading "0"
    # - 11. if high resolution then split by ":"
    # - 12. if nchar = 1 for first/last, then paste a leading "0"
    # - 13. keep only first 2 chars for low resolution
    # - 14. combine 1st and last parts into one with ":"

    letters_only <- function(x) !grepl("[^A-Za-z]", x)

    tmp <- data.frame(cbind(var_1, var_2)) %>%
      mutate(v1 = ifelse(var_1 %in% vec_na, "", var_1), # if string in vec_na then set to NA
             v2 = ifelse(var_2 %in% vec_na, "", var_2)) %>%
      mutate(v1.0 =  gsub("[[:space:]]", "", v1), # if string in vec_na then set to NA
             v2.0 =  gsub("[[:space:]]", "", v2)) %>%
      mutate(v1.1 = str_trim(v1.0), # remove white spaces around the string
             v2.1 = str_trim(v2.0)) %>%
      mutate(v1.2 = ifelse(letters_only(v1.1), "", v1.1), # if string contains ALL letters then set to NA
             v2.2 = ifelse(letters_only(v2.1), "", v2.1)) %>%
      mutate(v1.3 = ifelse(str_detect(v1.2, brkt_l), str_replace(v1.2, brkt_l, "("), v1.2),
             v2.3 = ifelse(str_detect(v2.2, brkt_l), str_replace(v2.2, brkt_l, "("), v2.2)) %>% # replace all brackets to round
      mutate(v1.3 = ifelse(str_detect(v1.3, brkt_r), str_replace(v1.3, brkt_r, ")"), v1.3),
             v2.3 = ifelse(str_detect(v2.3, brkt_r), str_replace(v2.3, brkt_r, ")"), v2.2)) %>%
      mutate(v1.4 = str_replace(v1.3, "\\([^\\)]+\\)", ""), # remove everything within brackets inclusively
             v2.4 = str_replace(v2.3, "\\([^\\)]+\\)", "")) %>%
      mutate(v1.5 = ifelse(str_detect(v1.4, "\\*{0,}+X{1,}"), str_replace(v1.4, "\\*{0,}+X{1,}", ""), v1.4), # remove **XXX pattern
             v2.5 = ifelse(str_detect(v2.4, "\\*{0,}+X{1,}"), str_replace(v2.4, "\\*{0,}+X{1,}", ""), v2.4)) %>%
      mutate(v1.6 = ifelse(str_count(v1.5, ":") > 1, sub("(:[^:]+):.*", "\\1", v1.5), v1.5), # remove :56 from 12:34:56
             v2.6 = ifelse(str_count(v2.5, ":") > 1, sub("(:[^:]+):.*", "\\1", v2.5), v2.5)) %>%
      mutate(v1.7 =  gsub("(?!\\:)[[:punct:]]", "", v1.6, perl = TRUE), # remove all punctuation marks except ":"
             v2.7 =  gsub("(?!\\:)[[:punct:]]", "", v2.6, perl = TRUE)) %>%
      mutate(v1.8 =  gsub("[A-Za-z]", "", v1.7), # remove if letter left
             v2.8 =  gsub("[A-Za-z]", "", v2.7)) %>%
      mutate(v1.9 = ifelse((!str_detect(v1.8, ":") & nchar(v1.8) == 1), paste0("0", v1.8), v1.8), # paste a leading "0" for 1 char low resolution antigen
             v2.9 = ifelse((!str_detect(v2.8, ":") & nchar(v2.8) == 1), paste0("0", v2.8), v2.8)) %>%
      mutate(v1.1st = ifelse(str_detect(v1.9, ":"), gsub(":.*", "", v1.9), ""), # if high resolution then split
             v1.last = ifelse(str_detect(v1.9, ":"), gsub(".*:", "", v1.9), ""),
             v2.1st = ifelse(str_detect(v2.9, ":"), gsub(":.*", "", v2.9), ""),
             v2.last = ifelse(str_detect(v2.9, ":"), gsub(".*:", "", v2.9), "")) %>%
      mutate(v1.1st.2 = ifelse(nchar(v1.1st) == 1, paste0("0", v1.1st), v1.1st), # if nchar = 1 for first/last, then paste a leading "0"
             v1.last.2 = ifelse(nchar(v1.last) == 1, paste0("0", v1.last), v1.last),
             v2.1st.2 = ifelse(nchar(v2.1st) == 1, paste0("0", v2.1st), v2.1st),
             v2.last.2 = ifelse(nchar(v2.last) == 1, paste0("0", v2.last), v2.last)) %>%
      mutate(v1.10 = ifelse(v1.1st.2 != "" & v1.last.2 != "", paste(v1.1st.2, v1.last.2, sep = ":"), v1.9), # combine first and last back
             v2.10 = ifelse(v2.1st.2 != "" & v2.last.2 != "", paste(v2.1st.2, v2.last.2, sep = ":"), v2.9)) %>%
      mutate(v1.11 = ifelse(!str_detect(v1.10, ":") & nchar(v1.10) > 2, str_sub(v1.10, 1, 2), v1.10), # if low resolution then keep only 2 chars
             v2.11 = ifelse(!str_detect(v2.10, ":") & nchar(v2.10) > 2, str_sub(v2.10, 1, 2), v2.10)) %>%
      mutate(clean1 = ifelse(str_detect(v1.11, ":") & nchar(v1.11) == 3, str_remove(v1.11, ":"), v1.11), # if low resolution then keep only 2 chars
             clean2 = ifelse(str_detect(v2.11, ":") & nchar(v2.11) == 3, str_remove(v2.11, ":"), v2.11)) %>%
      select(var_1, v1, v1.2, v1.2, v1.3, v1.4, v1.5, v1.6, v1.7, v1.8, v1.1st, v1.last, v1.1st.2, v1.last.2, v1.9, v1.10, v1.11, clean1,
             var_2, v2, v2.1, v2.2, v2.3, v2.4, v2.5, v2.6, v2.7, v2.8, v2.1st, v2.last, v2.1st.2, v2.last.2, v2.9, v2.10, v2.11, clean2)
    #* end of step 2 *#

    #* step 3: final table *#
    result <- tmp %>%
      mutate(locus1_clean = ifelse(clean1 != "", clean1, ifelse(clean2 != "", clean2, "")),
             locus2_clean = ifelse(clean2 != "", clean2, ifelse(clean1 != "", clean1, ""))) %>%
      select(var_1, var_2, locus1_clean, locus2_clean)
    #* end of step 3*#
    return(result)
  }
