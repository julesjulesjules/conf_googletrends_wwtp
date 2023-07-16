#### Analysis Code - Google Trends Poster
#### Julie Gilbert
#### 20 April 2023

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

combined_trend2$Interest <- as.numeric(combined_trend2$Interest)
combined_trend2$value <- as.numeric(combined_trend2$value)
combined_trend2$seven_day_rolling_average <- as.numeric(combined_trend2$seven_day_rolling_average)

value_correlations <- combined_trend2 %>% group_by(type, organism, location, pretty_word, city) %>% summarize(correlation=cor(value, Interest))
value_correlations$pretty_title <- paste0(value_correlations$organism, " (", value_correlations$type, ")")
value_correlations <- value_correlations %>% mutate(over_limit = case_when(correlation > 0.75 ~ "+/- 0.75", 
                                                                           correlation < -0.75 ~ "+/- 0.75",
                                                                           correlation > 0.5 ~ "+/- 0.5", 
                                                                           correlation < -0.5 ~ "+/- 0.5", 
                                                                           T ~ NA_character_))

ggplot(filter(value_correlations, location == "Detroit.MI."), aes(x = city, y = correlation)) + 
  geom_bar(stat = "identity") + 
  geom_point(aes(x = city, y = correlation, shape = over_limit)) +
  scale_shape_manual(values = c(1, 8)) +
  theme_bw() +
  ylim(-1, 1) +
  labs(title = "Correlations between Google Trend Interest and Wastewater Measurements",
       subtitle = "Detroit Region", 
       x = "", 
       y = "Correlation Coefficient", 
       shape = "") +
  # geom_hline(yintercept = c(-1, -0.5, 0, 0.5, 1), linetype = "dashed") +
  # geom_hline(yintercept = c(-0.75, -0.25, 0.25, 0.75), linetype = "dotted") +
  facet_wrap(pretty_title ~ pretty_word)


ggplot(filter(value_correlations, location == "Michigan."), aes(x = city, y = correlation)) + 
  geom_bar(stat = "identity") + 
  geom_point(aes(x = city, y = correlation, shape = over_limit)) +
  scale_shape_manual(values = c(1, 8)) +
  theme_bw() +
  ylim(-1, 1) +
  labs(title = "Correlations between Google Trend Interest and Wastewater Measurements",
       subtitle = "Michigan", 
       x = "", 
       y = "Correlation Coefficient", 
       shape = "") +
  # geom_hline(yintercept = c(-1, -0.5, 0, 0.5, 1), linetype = "dashed") +
  # geom_hline(yintercept = c(-0.75, -0.25, 0.25, 0.75), linetype = "dotted") +
  facet_wrap(pretty_title ~ pretty_word)



value_correlations2 <- combined_trend2 %>% group_by(type, organism, location, pretty_word, city) %>% summarize(correlation=cor(seven_day_rolling_average, Interest, use = "complete.obs"))
value_correlations2$pretty_title <- paste0(value_correlations2$organism, " (", value_correlations2$type, ")")
value_correlations2 <- value_correlations2 %>% mutate(over_limit = case_when(correlation > 0.75 ~ "+/- 0.75", 
                                                                           correlation < -0.75 ~ "+/- 0.75",
                                                                           correlation > 0.5 ~ "+/- 0.5", 
                                                                           correlation < -0.5 ~ "+/- 0.5", 
                                                                           T ~ NA_character_))

ggplot(filter(value_correlations2, location == "Detroit.MI."), aes(x = city, y = correlation)) + 
  geom_bar(stat = "identity") + 
  geom_point(aes(x = city, y = correlation, shape = over_limit)) +
  scale_shape_manual(values = c(1, 8)) +
  theme_bw() +
  ylim(-1, 1) +
  labs(title = "Correlations between Google Trend Interest and Rolling Average Wastewater Measurements",
       subtitle = "Detroit Region", 
       x = "", 
       y = "Correlation Coefficient", 
       shape = "") +
  # geom_hline(yintercept = c(-1, -0.5, 0, 0.5, 1), linetype = "dashed") +
  # geom_hline(yintercept = c(-0.75, -0.25, 0.25, 0.75), linetype = "dotted") +
  facet_wrap(pretty_title ~ pretty_word)


ggplot(filter(value_correlations2, location == "Michigan."), aes(x = city, y = correlation)) + 
  geom_bar(stat = "identity") + 
  geom_point(aes(x = city, y = correlation, shape = over_limit)) +
  scale_shape_manual(values = c(1, 8)) +
  theme_bw() +
  ylim(-1, 1) +
  labs(title = "Correlations between Google Trend Interest and Rolling Average Wastewater Measurements",
       subtitle = "Michigan", 
       x = "", 
       y = "Correlation Coefficient", 
       shape = "") +
  # geom_hline(yintercept = c(-1, -0.5, 0, 0.5, 1), linetype = "dashed") +
  # geom_hline(yintercept = c(-0.75, -0.25, 0.25, 0.75), linetype = "dotted") +
  facet_wrap(pretty_title ~ pretty_word)


value_correlations$corrtype <- "value"
value_correlations2$corrtype <- "rolling"
corrs <- rbind(value_correlations, value_correlations2)
corrs <- filter(corrs, !is.na(over_limit))


a <- filter(value_correlations, organism == "Norovirus")
a$fully <- paste0(a$location, " + ", a$pretty_word)

ggplot(a, aes(x = city, y = fully, fill = correlation)) + 
  geom_tile() +
  scale_fill_gradient2(limits=c(-1, 1), breaks=seq(-1,1,by=0.25), low="#3B3561", mid = "white", high="#51A3A3", midpoint = 0) + 
  theme_bw() + 
  labs(x = "", 
       y = "", 
       fill = "Correlation", 
       title = paste0(unique(a$pretty_title))) + 
  geom_text(data = a, aes(x = city, y = fully, label = round(correlation, 4)))



a <- filter(value_correlations, organism == "SARS-CoV-2")
a$fully <- paste0(a$location, " + ", a$pretty_word)

ggplot(a, aes(x = city, y = fully, fill = correlation)) + 
  geom_tile() +
  scale_fill_gradient2(limits=c(-1, 1), breaks=seq(-1,1,by=0.25), low="#3B3561", mid = "white", high="#51A3A3", midpoint = 0) + 
  theme_bw() + 
  labs(x = "", 
       y = "", 
       fill = "Correlation", 
       title = paste0(unique(a$pretty_title))) + 
  geom_text(data = a, aes(x = city, y = fully, label = round(correlation, 4)))


a <- filter(value_correlations, organism == "RSV")
a$fully <- paste0(a$location, " + ", a$pretty_word)

ggplot(a, aes(x = city, y = fully, fill = correlation)) + 
  geom_tile() +
  scale_fill_gradient2(limits=c(-1, 1), breaks=seq(-1,1,by=0.25), low="#3B3561", mid = "white", high="#51A3A3", midpoint = 0) + 
  theme_bw() + 
  labs(x = "", 
       y = "", 
       fill = "Correlation", 
       title = paste0(unique(a$pretty_title))) + 
  geom_text(data = a, aes(x = city, y = fully, label = round(correlation, 4)))



a <- filter(value_correlations, organism == "Influenza A")
a$fully <- paste0(a$location, " + ", a$pretty_word)

ggplot(a, aes(x = city, y = fully, fill = correlation)) + 
  geom_tile() +
  scale_fill_gradient2(limits=c(-1, 1), breaks=seq(-1,1,by=0.25), low="#3B3561", mid = "white", high="#51A3A3", midpoint = 0) + 
  theme_bw() + 
  labs(x = "", 
       y = "", 
       fill = "Correlation", 
       title = paste0(unique(a$pretty_title))) + 
  geom_text(data = a, aes(x = city, y = fully, label = round(correlation, 4)))

