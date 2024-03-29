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

################################################################################
# make a chart of google trends data with zone of sample data highlighted


ww_data <- rbind(select(covid_ww, Date, city, organism, variable, type), select(noro_ww, Date, city, organism, variable, type), select(solid_ww, Date, city, organism, variable, type))

ww_data2 <- ww_data %>% group_by(type, organism, variable) %>% summarize(min_date = min(Date), 
                                                                               max_date = max(Date))

ww_data2[is.na(ww_data2)] <- ""

ww_data2 <- filter(ww_data2, organism %in% c("RSV", "Norovirus", "Influenza A", "SARS-CoV-2") & variable != "N2")

combined_trend2 <- merge(combined_trend, ww_data2, by.x = c("organism"), by.y = c("organism"), all = TRUE)

ggplot(combined_trend2, aes(x = as_date(Week), y = as.numeric(Interest), color = location)) + 
  geom_line(size = 1, alpha = 0.6) + 
  geom_ribbon(data = filter(combined_trend2, as_date(Week) > as_date("2021-01-01")), aes(xmin = as_date(min_date), xmax = as_date(max_date)), color = "grey", alpha = 0.3) + 
  theme_bw() +
  scale_color_manual(values = c("#7F636E", "#003559")) + 
  labs(x = "",
       y = "Google Trends Interest Count", 
       color = "Region") +
  facet_wrap(.~pretty_word)


ww_data <- rbind(select(covid_ww, Date, city, organism, variable, type, value), select(noro_ww, Date, city, organism, variable, type, value), select(solid_ww, Date, city, organism, variable, type, value))

ww_data3 <- filter(ww_data, organism %in% c("RSV", "Norovirus", "Influenza A", "SARS-CoV-2"))
ww_data3 <- ww_data3 %>% mutate(cutout = case_when(organism == "SARS-CoV-2" & type == "SOLID" ~ "out", 
                                                   organism == "SARS-CoV-2" & variable == "N2" ~ "out",
                                                   T ~ "in"))

ww_data3 <- filter(ww_data3, cutout == "in")


ww_data3a <- filter(ww_data3, organism == "RSV" & value < 0.001) %>% distinct(Date, city, .keep_all = TRUE)

max(ww_data3a$Date)
min(ww_data3a$Date)

sample_count <- ww_data3a %>% group_by(city, year(Date), epiweek(Date)) %>% summarize(sample_count = length(value))
mean(sample_count$sample_count)

combined_trenda <- filter(combined_trend, organism == "RSV" )

combined_trenda <- filter(combined_trenda, as_date(Week) >= as_date("2022-07-01"))

ggplot() + 
  geom_line(data = combined_trenda, aes(x = as_date(Week), y = as.numeric(Interest)/100000, color = pretty_word), size = 1, alpha = 0.8) + 
  geom_point(data = ww_data3a, aes(x = as_date(Date), y = value), alpha = 0.3) +
  # geom_ribbon(data = filter(combined_trend2, as_date(Week) > as_date("2021-01-01")), aes(xmin = as_date(min_date), xmax = as_date(max_date)), color = "grey", alpha = 0.3) + 
  theme_bw() +
  scale_x_date(date_labels = "%b %Y") +
  scale_color_manual(values = c("#E85F5C", "#7D8491", "#E0C200", "#57C4E5")) + 
  labs(x = "",
       #y = "Google Trends Interest Count", 
       color = "Keyword") +
  scale_y_continuous(
    # Features of the first axis
    name = "PMMoV-Normalized Wastewater Detection",
    # Add a second axis and specify its features
    sec.axis = sec_axis( trans=~.*100000, name="Google Trends Interest Count")
  ) +
  facet_wrap(.~organism+location, scale = "free")


ww_data3a <- filter(ww_data3, organism == "SARS-CoV-2") %>% distinct(Date, city, .keep_all = TRUE)

max(ww_data3a$Date)
min(ww_data3a$Date)

sample_count <- ww_data3a %>% group_by(city, year(Date), epiweek(Date)) %>% summarize(sample_count = length(value))
mean(sample_count$sample_count)

combined_trenda <- filter(combined_trend, organism == "SARS-CoV-2" )

combined_trenda <-  filter(combined_trenda, as_date(Week) >= as_date("2021-06-01"))

ggplot() + 
  geom_point(data = ww_data3a, aes(x = as_date(Date), y = value), alpha = 0.2) +
  geom_line(data = combined_trenda, aes(x = as_date(Week), y = as.numeric(Interest)/10000, color = pretty_word), size = 1, alpha = 0.8) + 
  # geom_ribbon(data = filter(combined_trend2, as_date(Week) > as_date("2021-01-01")), aes(xmin = as_date(min_date), xmax = as_date(max_date)), color = "grey", alpha = 0.3) + 
  theme_bw() +
  scale_x_date(date_labels = "%b %Y") +
  scale_color_manual(values = c("#E0C200", "#57C4E5", "#E85F5C", "#7D8491")) + 
  labs(x = "",
       #y = "Google Trends Interest Count", 
       color = "Keyword") +
  scale_y_continuous(
    # Features of the first axis
    name = "PMMoV-Normalized Wastewater Detection",
    # Add a second axis and specify its features
    sec.axis = sec_axis( trans=~.*10000, name="Google Trends Interest Count")
  ) +
  facet_wrap(.~organism+location, scale = "free")



ww_data3a <- filter(ww_data3, organism == "Influenza A") %>% arrange(city, Date) %>% distinct(Date, city, .keep_all = TRUE)

max(ww_data3a$Date)
min(ww_data3a$Date)

sample_count <- ww_data3a %>% group_by(city, year(Date), epiweek(Date)) %>% summarize(sample_count = length(value))
mean(sample_count$sample_count)

combined_trenda <- filter(combined_trend, organism == "Influenza A" ) 

combined_trenda <- filter(combined_trenda, as_date(Week) >= as_date("2022-07-01"))

ggplot() + 
  geom_line(data = combined_trenda, aes(x = as_date(Week), y = as.numeric(Interest)/100000, color = pretty_word), size = 1, alpha = 0.8) + 
  geom_point(data = ww_data3a, aes(x = as_date(Date), y = value), alpha = 0.3) +
  # geom_ribbon(data = filter(combined_trend2, as_date(Week) > as_date("2021-01-01")), aes(xmin = as_date(min_date), xmax = as_date(max_date)), color = "grey", alpha = 0.3) + 
  theme_bw() +
  scale_x_date(date_labels = "%b %Y") +
  scale_color_manual(values = c("#E85F5C", "#7D8491", "#E0C200", "#57C4E5")) + 
  labs(x = "",
       #y = "Google Trends Interest Count", 
       color = "Keyword") +
  scale_y_continuous(
    # Features of the first axis
    name = "PMMoV-Normalized Wastewater Detection",
    # Add a second axis and specify its features
    sec.axis = sec_axis( trans=~.*100000, name="Google Trends Interest Count")
  ) +
  facet_wrap(.~organism+location, scale = "free")


ww_data3a <- filter(ww_data3, organism == "Norovirus") %>% arrange(city, Date) %>% distinct(Date, city, .keep_all = TRUE)

max(ww_data3a$Date)
min(ww_data3a$Date)

sample_count <- ww_data3a %>% group_by(city, year(Date), epiweek(Date)) %>% summarize(sample_count = length(value))
mean(sample_count$sample_count)

combined_trenda <- filter(combined_trend, organism == "Norovirus" )

combined_trenda <- filter(combined_trenda, as_date(Week) >= as_date("2021-07-01"))

ggplot() + 
  geom_line(data = combined_trenda, aes(x = as_date(Week), y = as.numeric(Interest)/200, color = pretty_word), size = 1, alpha = 0.8) + 
  geom_point(data = ww_data3a, aes(x = as_date(Date), y = value), alpha = 0.3) +
  # geom_ribbon(data = filter(combined_trend2, as_date(Week) > as_date("2021-01-01")), aes(xmin = as_date(min_date), xmax = as_date(max_date)), color = "grey", alpha = 0.3) + 
  theme_bw() +
  scale_x_date(date_labels = "%b %Y") +
  scale_color_manual(values = c("#E85F5C", "#7D8491", "#E0C200", "#57C4E5")) + 
  labs(x = "",
       #y = "Google Trends Interest Count", 
       color = "Keyword") +
  scale_y_continuous(
    # Features of the first axis
    name = "PMMoV-Normalized Wastewater Detection",
    # Add a second axis and specify its features
    sec.axis = sec_axis( trans=~.*200, name="Google Trends Interest Count")
  ) +
  facet_wrap(.~organism+location, scale = "free")

