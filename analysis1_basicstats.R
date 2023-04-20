#### Analysis Code - Google Trends Poster
#### Julie Gilbert
#### 20 April 2023

library(tidyverse)
library(lubridate)

################################################################################
### Wastewater Sample Data - Basic Stats

# solids 
solid_ww <- read.csv("~/UofM_Work/sewer_conference_google_trends/wwtp_sample_data/solid_wastewater_data_all_cities.csv")

filter(solid_ww, organism %in% c("RSV", "SARS-CoV-2", "Influenza A")) %>% group_by(city, organism, variable) %>% summarize(min_date = min(Date), 
                                                              max_date = max(Date), 
                                                              total_count = length(value))


# covid ww influent
covid_ww <- read.csv("~/UofM_Work/sewer_conference_google_trends/wwtp_sample_data/covid_wastewater_data_all_cities.csv")

filter(covid_ww, variable == "N1") %>% group_by(city, organism, variable) %>% summarize(min_date = min(Date), 
                                                              max_date = max(Date), 
                                                              total_count = length(value))

# norovirus ww influent
noro_ww <- read.csv("~/UofM_Work/sewer_conference_google_trends/wwtp_sample_data/norov_wastewater_data_all_cities.csv")

filter(noro_ww) %>% group_by(city, organism, variable) %>% summarize(min_date = min(Date), 
                                                                                        max_date = max(Date), 
                                                                                        total_count = length(value))



################################################################################
# read in google trends data



################################################################################
# make a chart of google trends data with zone of sample data highlighted



