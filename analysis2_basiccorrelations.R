#### Analysis Code - Google Trends Poster
#### Julie Gilbert
#### 20 April 2023

library(tidyverse)
library(lubridate)

################################################################################
### Wastewater Sample Data - Basic Stats

# solids 
solid_ww <- read.csv("~/UofM_Work/sewer_conference_google_trends/wwtp_sample_data/solid_wastewater_data_all_cities.csv")


# covid ww influent
covid_ww <- read.csv("~/UofM_Work/sewer_conference_google_trends/wwtp_sample_data/covid_wastewater_data_all_cities.csv")


# norovirus ww influent
noro_ww <- read.csv("~/UofM_Work/sewer_conference_google_trends/wwtp_sample_data/norov_wastewater_data_all_cities.csv")


################################################################################
# read in google trends data


all_trend_files <- list.files("~/UofM_Work/sewer_conference_google_trends/google_trend_data_files/")

combined_trend <- data.frame()

for (i in all_trend_files){
  fin <- read.csv(paste0("~/UofM_Work/sewer_conference_google_trends/google_trend_data_files/", i), skip = 2)
  name_info <- colnames(fin)[2]
  colnames(fin) <- c("Week", "Interest")
  fin$keyword <- strsplit(name_info, "\\.\\.\\.")[[1]][1]
  fin$location <- strsplit(name_info, "\\.\\.\\.")[[1]][2]
  
  combined_trend <- rbind(combined_trend, fin)
}


#table(combined_trend$keyword)

combined_trend <- combined_trend %>% mutate(organism = case_when(keyword %in% c("covid", "covid.symptoms") ~ "SARS-CoV-2", 
                                                                 keyword %in% c("flu", "flu.symptoms", "influenza", "influenza.symptoms") ~ "Influenza A", 
                                                                 keyword %in% c("norovirus", "norovirus.symptoms", "stomach.flu", "stomach.flu.symptoms") ~ "Norovirus", 
                                                                 keyword %in% c("rsv", "rsv.symptoms") ~ "RSV", 
                                                                 T ~ "unknown"))

combined_trend <- combined_trend %>% mutate(pretty_word = paste0('"', gsub("\\.", " ", keyword), '"'))



