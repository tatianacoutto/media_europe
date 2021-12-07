## 
## Clean data collected on Le Monde and turn it into rds dataset
## 
## The raw data has been scraped using a .NET tool 
## 
## Tatiana Coutto
##
## October 2021
## 


library(tidyverse)
library(here)

source(here("cleaning","funs_cleaning.R"))

dat <- list.files(here("data","scraped_newspapers","lemonde","dennis")) %>% 
  str_subset("json") %>%
  map_dfr(dennisjson_to_df_safe,"lemonde") %>% 
  distinct() %>% 
  mutate(language = "fr")

# Select the relevant variables 
dat <- dat %>% select(
  url,
  newspaper, 
  language, 
  date, 
  title, 
  subtitle, 
  body=text, 
  section, 
  authors
) %>% 
  # Remove duplicates (several obs have same url but different id)
  distinct()

# Clean authors
authorsdb <- dat %>% 
  select(url,authors) %>% 
  unnest(cols = c(authors)) %>% 
  select(-authors) %>% 
  rename(authors=name) %>% 
  mutate(authors = authors %>% str_remove("PROPOS RECUEILLIS PAR "), 
         authors = authors %>% str_remove("^PAR "), 
         authors = authors %>% str_to_title()) 

dat <- dat %>% 
  select(-authors) %>% 
  left_join(authorsdb, by = "url") 

dat %>% glimpse

# Check number of observations and duplicates on url
dat %>% glimpse
dat %>% select(url) %>% distinct() %>% dim()

# Filter europ/brexit in title/body
dat <- dat %>% filter(str_detect(str_to_lower(title), "europ|brexit") |
                        str_detect(str_to_lower(body), "europ|brexit"))

# Clean ugly dates
dat <- dat %>% 
  filter(!is.na(date)) %>% 
  filter(date > "1985-01-01")

# Save the data
dat %>% write_rds(here("data","clean_newspapers","lemonde.rds"))
