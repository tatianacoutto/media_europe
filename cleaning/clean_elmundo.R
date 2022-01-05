## 
## Clean data collected on El Mundo and turn it into rds dataset
## 
## The raw data has been scraped using a .NET tool  
## partly some manual collection on Factiva (1995-2005)
##
## Tatiana Coutto
##
## December 2021
## 

library(tidyverse)
library(here)

source(here("cleaning","funs_cleaning.R"))

# dat <- list.files(here("data","scraped_newspapers","elmundo","dennis")) %>% 
#   str_subset("json") %>%
#   map_dfr(dennisjson_to_df_safe,"elmundo") %>% 
#   distinct() %>% 
#   mutate(language = "es")
# 
# # Select the relevant variables 
# dat <- dat %>% select(
#   url,
#   newspaper, 
#   language, 
#   date, 
#   title, 
#   subtitle, 
#   body=text, 
#   section, 
#   authors
# ) %>% 
#   # Remove duplicates (several obs have same url but different id)
#   distinct()
# 
# # Clean authors
# authorsdb <- dat %>% 
#   select(url,authors) %>% 
#   unnest(cols = c(authors)) %>% 
#   select(-authors) %>% 
#   rename(authors=name) %>% 
#   mutate(authors = authors %>% str_remove("PROPOS RECUEILLIS PAR "), 
#          authors = authors %>% str_to_title()) 
# 
# dat <- dat %>% 
#   select(-authors) %>% 
#   left_join(authorsdb, by = "url") 
# 
# # Check number of observations and duplicates on url
# dat %>% glimpse
# dat %>% select(url) %>% distinct() %>% dim()
# 
# # Check time coverage
# dat %>% 
#   filter(date > "1985-01-01") %>%
#   ggplot(aes(date)) + geom_histogram(binwidth = 3600*24*7) 
# 
# dat %>% 
#   filter (date >"2015-09-15", date < "2018-01-01")%>%
#   ggplot(aes(date)) + geom_histogram(binwidth = 3600*24*7) 


## 2. Data manually collected

dat <- here("data","scraped_newspapers","elmundo","factiva") %>% 
  list.files() %>% 
  str_subset("html") %>%
  map_dfr(factiva_to_df_safe,"elmundo") %>% 
  distinct()

# Check number of observations and missing dates
dat %>% count(is.na(date))
dat %>% glimpse

dat %>% select(date) %>% skimr::skim()
dat %>% filter(date > "1000-01-01") %>% select(date) %>% skimr::skim()

# Filter on europ/brexit in title or body
dat <- dat %>% filter(str_detect(str_to_lower(title), "europ|brexit") |
                        str_detect(str_to_lower(body), "europ|brexit")) 

# # Get rid of non-El Mundo newspapers
# dat %>% count(newspaper)
# dat <- dat %>% filter(newspaper == "El Mundo")

# # Get rid of ugly dates
# dat <- dat %>% filter(date > "1900-01-01")

# Language -> "es"
dat <- dat %>% mutate(language = "es")

# Save the data
dat %>% 
  write_rds(here("data","clean_newspapers","elmundo.rds"))

# # Read the data
# dat <- read_rds(here("data","clean_newspapers","elmundo.rds"))
# dat %>% count(language)
