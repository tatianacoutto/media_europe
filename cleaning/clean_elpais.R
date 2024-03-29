## 
## Clean data collected on El Pais and turn it into rds dataset
## 
## The raw data has been scraped using manual collection on Factiva
## 
##
## Tatiana Coutto
##
## December 2021
## 

library(tidyverse)
library(here)
library(newspapers) # remotes::install_github("koheiw/newspapers")

source(here("cleaning","funs_cleaning.R"))

mdat <- here("data","scraped_newspapers","elpais","factiva") %>% 
  list.files() %>% 
  str_subset("html") %>%
  map_dfr(factiva_to_df_safe,"elpais") %>% 
  distinct()

mdat %>% glimpse
mdat %>% skimr::skim() 

# Update language
mdat <- mdat %>% 
  mutate(language = "es", 
         newspaper = "El Pais")

mdat <- mdat %>% filter(str_detect(str_to_lower(title), "europ|brexit") |
                          str_detect(str_to_lower(body), "europ|brexit"))

# Check number of observations and missing dates
mdat %>% glimpse
mdat %>% count(is.na(date))

# Check time coverage
mdat %>% 
  # filter(date > "2001-05-20") %>%
  # filter(date < "2002-02-01") %>%
  ggplot(aes(date)) + geom_histogram(binwidth = 7) 

# Save the data
mdat %>% 
  write_rds(here("data","clean_newspapers","elpais.rds"))
