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

| Organism | Sample Collection Type | WWTP | Sample Collection Date Range | Total Samples |
| --- | --- | --- | --- | --- |
| SARS-CoV-2 (N1) | Solid | AA | 2022-09-21 to 2023-04-10 | 91 |
| SARS-CoV-2 (N1) | Solid | FL | 2022-09-28 to 2023-04-10 | 84 |
| SARS-CoV-2 (N1) | Solid | JS | 2022-09-02 to 2023-04-10 | 85 |
| SARS-CoV-2 (N1) | Solid | TM | 2022-09-22 to 2023-04-11 | 86 |
| SARS-CoV-2 (N1) | Solid | YC | 2022-09-23 to 2023-04-11 | 83 |
| SARS-CoV-2 (N1) | Influent | AA | 2021-07-06 to 2023-04-13 | 637 |
| SARS-CoV-2 (N1) | Influent | FL | 2021-07-12 to 2023-04-13 | 586 |
| SARS-CoV-2 (N1) | Influent | JS | 2021-07-12 to 2023-04-13 | 529 |
| SARS-CoV-2 (N1) | Influent | TM | 2022-01-13 to 2023-04-14 | 422 |
| SARS-CoV-2 (N1) | Influent | YC | 2021-07-08 to 2023-04-13 | 591 |
| Influenza A | Solid | AA | 2022-09-21 to 2023-04-10 | 98 |
| Influenza A | Solid | FL | 2022-09-28 to 2023-04-10 | 86 |
| Influenza A | Solid | JS | 2022-09-02 to 2023-04-10 | 89 |
| Influenza A | Solid | TM | 2022-09-22 to 2023-04-11 | 91 |
| Influenza A | Solid | YC | 2022-09-23 to 2023-04-11 | 89 |
| Norovirus | Influent | AA | 2021-09-07 2023-04-10 | 232 |
| Norovirus | Influent | FL | 2021-09-14 2023-04-10 | 202 |
| Norovirus | Influent | JS | 2021-09-07 2023-04-10 | 219 |
| Norovirus | Influent | TM | 2022-01-13 2023-04-11 | 253 |
| Norovirus | Influent | YC | 2021-09-14 2023-04-10 | 251 |
| RSV | Solid | AA | 2022-11-01 to 2023-04-10 | 90 |
| RSV | Solid | FL | 2022-11-01 to 2023-04-10 | 82 |
| RSV | Solid | JS | 2022-11-01 to 2023-04-10 | 83 |
| RSV | Solid | TM | 2022-11-02 to 2023-04-11 | 84 |
| RSV | Solid | YC | 2022-11-02 t0 2023-04-11 | 81 |
