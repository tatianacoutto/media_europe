## 
## Clean data collected on Corriere della Sera and turn it into rds dataset
## 
## The raw data has been scraped using manual collection on Factiva
## 
##
## Tatiana Coutto
##
## October 2021
## 

library(tidyverse)
library(here)
library(newspapers) # remotes::install_github("koheiw/newspapers")

source(here("cleaning","funs_cleaning.R"))

mdat <- here("data","scraped_newspapers","corriere","factiva") %>% 
  list.files() %>% 
  str_subset("html") %>%
  map_dfr(factiva_to_df_safe,"corriere") %>% 
  distinct()

# Update language
mdat <- mdat %>% 
  mutate(language = "it")

# Check number of observations and missing dates
mdat %>% glimpse
mdat %>% count(is.na(date))

# Check time coverage
mdat %>% 
  filter(date > "1985-01-01") %>%
  ggplot(aes(date)) + geom_histogram(binwidth = 24*7) 

# Save the data
mdat %>% 
  write_rds(here("data","clean_newspapers","corriere.rds"))
