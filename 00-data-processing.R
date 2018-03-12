# Bantu ideophones
# Mark Dingemanse 2018 in collaboration with Annemarie Verkerk

# Clear workspace
rm(list=ls())

# check for /in/ and /out/ directories (create them if needed)
add_working_dir <- function(x) { if(file.exists(x)) { cat(x,"dir:",paste0(getwd(),"/",x,"/")) } else { dir.create(paste0(getwd(),"/",x)) 
  cat("subdirectory",x,"created in",getwd()) } }
add_working_dir("in")
add_working_dir("out")

# Packages and useful functions
list.of.packages <- c("tidyverse","readxl","stringr","openxlsx")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)>0) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)
rm(list.of.packages,new.packages)

`%notin%` <- function(x,y) !(x %in% y) 

# Load data ---------------------------------------------------------------

# List of Bantu languages from Glottolog (via Annemarie)
lg <- read_tsv("in/glottolog_Bantu_langs.txt") %>%
  dplyr::select(-contains("Grollemund"))

# List of ideophone hits in grambank PDF collection (via HH) 
hh <- read_tsv("in/hh_ideophone_hits.csv") %>%
  plyr::rename(c("ISO 639-3" = "hid","all (freq)" = "nwords","ideophone (freq)" = "freq_en","idêophone (freq)" = "freq_fr")) %>%
  dplyr::select(-starts_with("all (freq)_1")) %>%
  dplyr::select(-contains("(prop)")) %>%
  mutate(ideophone_freq = freq_fr + freq_en ) %>%
  mutate(ideophone_prop = ideophone_freq / nwords)

# Merge to keep only Bantu languages with grammars available in Grambank
df <- merge(lg,hh,by="hid")

# Are hh's bib keys unique? Then we can use that field as a unique identifier for coding
df$`hh.bib key` == unique(df$`hh.bib key`)

# Add coding fields
df$coder <- NA
df$id_info <- NA
df$id_phonology <- NA
df$id_morphology <- NA
df$id_syntax <- NA
df$id_syntax_notes <- NA
df$id_syntax_pp <- NA

# for writing XLSX we'll need zip from Rtools
Sys.setenv("R_ZIPCMD" = "C:/Rtools/bin/zip.exe")
write.xlsx(df,file="out/Bantu_ideophones.xlsx")
