#### Analysis Code - Google Trends Poster
#### Looking at SC2 Solids vs. Influent
#### Julie Gilbert
#### 8 May 2023

library(tidyverse)
library(lubridate)

################################################################################
### Wastewater Sample Data - Basic Stats

# solids 
solid_ww <- read.csv("~/UofM_Work/sewer_conference_google_trends/wwtp_sample_data/solid_wastewater_data_all_cities.csv")
solid_ww <- filter(solid_ww, organism != "SARS-CoV-2")

# covid ww influent
covid_ww <- read.csv("~/UofM_Work/sewer_conference_google_trends/wwtp_sample_data/covid_wastewater_data_all_cities.csv")
covid_ww <- filter(covid_ww, type != "SOLID")

# norovirus ww influent
noro_ww <- read.csv("~/UofM_Work/sewer_conference_google_trends/wwtp_sample_data/norov_wastewater_data_all_cities.csv")

##

ww_data <- rbind(select(covid_ww, Date, city, organism, variable, type, value, seven_day_rolling_average), select(noro_ww, Date, city, organism, variable, type, value, seven_day_rolling_average), select(solid_ww, Date, city, organism, variable, type, value, seven_day_rolling_average))

ww_data$variable[is.na(ww_data$variable)] <- ""

ww_data <- filter(ww_data, organism %in% c("RSV", "Norovirus", "Influenza A", "SARS-CoV-2") & variable != "N2")

ww_data <- ww_data %>% arrange(city, organism, Date) %>% distinct(Date, city, organism, .keep_all = TRUE)

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



combined_trend <- combined_trend %>% mutate(organism = case_when(keyword %in% c("covid", "covid.symptoms") ~ "SARS-CoV-2", 
                                                                 keyword %in% c("flu", "flu.symptoms", "influenza", "influenza.symptoms") ~ "Influenza A", 
                                                                 keyword %in% c("norovirus", "norovirus.symptoms", "stomach.flu", "stomach.flu.symptoms") ~ "Norovirus", 
                                                                 keyword %in% c("rsv", "rsv.symptoms") ~ "RSV", 
                                                                 T ~ "unknown"))

combined_trend <- combined_trend %>% mutate(pretty_word = paste0('"', gsub("\\.", " ", keyword), '"'))

# need to "fill in" all days for the trend data, so that we maximize joining with ww data

full_date_range <- seq.Date(from = min(as_date(combined_trend$Week)), to = max(as_date(combined_trend$Week)), by = 1)

fullset <- data.frame()

for (each_keyword in unique(combined_trend$keyword)){
  one_bit <- data.frame(full_date_range)
  one_bit$keyword <- each_keyword
  one_bit$location <- "Detroit.MI."
  fullset <- rbind(fullset, one_bit)
  
  one_bit <- data.frame(full_date_range)
  one_bit$keyword <- each_keyword
  one_bit$location <- "Michigan."
  fullset <- rbind(fullset, one_bit)
}


colnames(fullset) <- c("Day", "keyword", "location")
fullset$Day <- as.character(fullset$Day)

combined_trend$Week <- as.character(combined_trend$Week)

combined_trend <- merge(combined_trend, fullset, by.x = c("Week", "keyword", "location"), by.y = c("Day", "keyword", "location"), all = TRUE)

combined_trend <- combined_trend %>% arrange(location, keyword, Week)

combined_trend <- combined_trend %>% group_by(location, keyword) %>% arrange(Week) %>% fill(c(Interest, organism, pretty_word), .direction = c("down"))

combined_trend <- combined_trend %>% arrange(location, keyword, Week)

combined_trend2 <- merge(combined_trend, ww_data, by.x = c("organism", "Week"), by.y = c("organism", "Date"))

################################################################################

# get down to covid data only

sc2_trend <- filter(combined_trend2, organism == "SARS-CoV-2")


# want to look at SOLID correlations lagged different amounts

sc2_trend_solid <- filter(sc2_trend, type == "SOLID")

test_one <- filter(sc2_trend_solid, city == "AA" & keyword == "covid" & location == "Michigan.")

ccf(as.numeric(test_one$value), as.numeric(test_one$Interest), main = "Wastewater Lagged Against Google Trend")
# x is lagged against y

ggplot(test_one, aes(x = as_date(Week), y = value)) + 
  geom_point() + 
  geom_point(data = test_one, aes(x= as_date(Week), y = as.numeric(Interest)/100000), color = "blue") + 
  theme_bw() + 
  labs(x = "", 
       y = "", 
       title = "Blue = Google Trend for Michigan vs. Black = Solid SARS-CoV-2 Detection")


test_one_early <- filter(test_one, as_date(Week) <= as_date("2022-01-01"))

ccf(as.numeric(test_one_early$value), as.numeric(test_one_early$Interest), main = "Wastewater Lagged Against Google Trend")


test_one_late <- filter(test_one, as_date(Week) >= as_date("2022-01-01"))

ccf(as.numeric(test_one_late$value), as.numeric(test_one_late$Interest), main = "Wastewater Lagged Against Google Trend")




# want to look at INFLUENT correlations lagged different amounts

sc2_trend_inf <- filter(sc2_trend, type == "INFLUENT")

test_two <- filter(sc2_trend_inf, city == "AA" & keyword == "covid" & location == "Michigan.")

ccf(as.numeric(test_two$value), as.numeric(test_two$Interest), main = "Wastewater Lagged Against Google Trend")


ggplot(test_two, aes(x = as_date(Week), y = value)) + 
  geom_point() + 
  geom_point(data = test_two, aes(x= as_date(Week), y = as.numeric(Interest)/100000), color = "blue") + 
  theme_bw() + 
  labs(x = "", 
       y = "", 
       title = "Blue = Google Trend for Michigan vs. Black = Influent SARS-CoV-2 Detection at AA WWTP")


test_two_early <- filter(test_two, as_date(Week) <= as_date("2022-01-01"))

ccf(as.numeric(test_two_early$value), as.numeric(test_two_early$Interest), main = "Wastewater Lagged Against Google Trend")


test_two_late <- filter(test_two, as_date(Week) >= as_date("2022-01-01"))

ccf(as.numeric(test_two_late$value), as.numeric(test_two_late$Interest), main = "Wastewater Lagged Against Google Trend")

