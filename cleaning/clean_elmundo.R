## 
## Clean data collected on El Mundo and turn it into rds dataset
## 
## The raw data has been scraped using a .NET tool  
## 
##
## Tatiana Coutto
##
## October 2021
## 

library(tidyverse)
library(here)

source(here("cleaning","funs_cleaning.R"))

dat <- list.files(here("data","scraped_newspapers","elmundo","dennis")) %>% 
  str_subset("json") %>%
  map_dfr(dennisjson_to_df_safe,"elmundo") %>% 
  distinct() %>% 
  mutate(language = "es")

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
         authors = authors %>% str_to_title()) 

dat <- dat %>% 
  select(-authors) %>% 
  left_join(authorsdb, by = "url") 

# Check number of observations and duplicates on url
dat %>% glimpse
dat %>% select(url) %>% distinct() %>% dim()

# Check time coverage
dat %>% 
  filter(date > "1985-01-01") %>%
  ggplot(aes(date)) + geom_histogram(binwidth = 3600*24*7) 

dat %>% 
  filter (date >"2015-09-15", date < "2017-01-01")%>%
  ggplot(aes(date)) + geom_histogram(binwidth = 3600*24*7) 

# Save the data
dat %>% 
  write_rds(here("data","clean_newspapers","elmundo.rds"))
