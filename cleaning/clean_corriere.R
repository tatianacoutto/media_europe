## 
## Clean data collected on Corriere della Sera and turn it into rds dataset
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

# Remove articles that DO NOT have either 
# europ or bruxelles or brexit in the title or body
# mdat %>% 
#   filter(!is.na(date)) %>% 
#   count( 
#   date >= "2005-01-01", 
#   str_detect(str_to_lower(title), "europ|brexit"))

mdat <- mdat %>% filter(str_detect(str_to_lower(title), "europ|brexit") |
                  str_detect(str_to_lower(body), "europ|brexit"))

# Issues with newpaper variable for a few (very few articles)
# For these articles, the date is instead of the newspaper, we amend this. 
mdat %>% count(newspaper)

mdat <- mdat %>% filter((newspaper %>% str_to_lower() %>% str_detect("cor"))) %>%  
  bind_rows(
    mdat %>% filter(!(newspaper %>% str_to_lower() %>% str_detect("cor"))) %>% 
      mutate(date = newspaper %>% lubridate::dmy(locale="fr_fr"), 
             newspaper = "Corriere della Sera")
  )
  
mdat %>% glimpse

# Harmonise newspaper name
mdat <- mdat %>% 
  mutate(newspaper = "Corriere della Sera")

# Save the data
mdat %>% 
  write_rds(here("data","clean_newspapers","corriere.rds"))
