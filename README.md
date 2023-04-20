# Google Trends Analysis - Conference Poster

This repository documents the code and analysis done for the poster "Triangulating Transmission Trends: Comparing Google Trends and Wastewater Surveillance Data for Multiple Pathogens" presented at the Go with the Flow: Public Health Wastewater Monitoring in Michigan conference on 17-18 May 2023, in East Lansing, Michigan.

# R Information - Used for Analysis

R version 4.0.3 (2020-10-10)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 18363)

Libraries:
tidyverse version 1.3.0
lubridate version 1.7.9.2

# Google Trends Data

Google Trend data was pulled on 20 April 2023 from https://trends.google.com/trends/explore?geo=US&hl=en. The "Interest Over Time" .csv files were downloaded for each search term and location combination.

| Search Term | Location Area | Time Period | Categories | Search Type |
| --- | --- | --- | --- | --- |
| "covid symptoms" | Michigan, Detroit MI | Past 5 years | All categories | Web Search |
| "covid" | Michigan, Detroit MI | Past 5 years | All categories | Web Search |
| "flu symptoms" | Michigan, Detroit MI | Past 5 years | All categories | Web Search |
| "flu" | Michigan, Detroit MI | Past 5 years | All categories | Web Search |
| "influenza symptoms" | Michigan, Detroit MI | Past 5 years | All categories | Web Search |
| "influenza" | Michigan, Detroit MI | Past 5 years | All categories | Web Search |
| "norovirus symptoms" | Michigan, Detroit MI | Past 5 years | All categories | Web Search |
| "norovirus" | Michigan, Detroit MI | Past 5 years | All categories | Web Search |
| "rsv symptoms" | Michigan, Detroit MI | Past 5 years | All categories | Web Search |
| "rsv" | Michigan, Detroit MI | Past 5 years | All categories | Web Search |
| "stomach flu symptoms" | Michigan, Detroit MI | Past 5 years | All categories | Web Search |
| "stomach flu" | Michigan, Detroit MI | Past 5 years | All categories | Web Search |

![](/image_files/google_trends_regions.PNG "Google Trends Search Regions")

# Wastewater Treatment Plant Concentration Measurement Data

Wastewater sample data as of 20 April 2023. All values are PMMoV-normalized. Samples are collected from five wastewater treatment plants from across south-east Michigan.

| Organism | Sample Collection Type | Sample Collection Date Range | Total Samples |
| --- | --- | --- | --- |
| SARS-CoV-2 (N1) | Solid |
| SARS-CoV-2 (N1) | Influent |
| Influenza A | Solid |
| Norovirus | Influent |
| RSV | Solid |
