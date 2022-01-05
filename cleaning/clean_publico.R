## 
## Clean data collected on Publico and turn it into rds dataset
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

dat <- list.files(here("data","scraped_newspapers","publico","dennis")) %>% 
  str_subset("json") %>%
  map_dfr(dennisjson_to_df_safe,"publico") %>% 
  distinct()

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

dat %>% glimpse

# Clean authors
# authorsdb <- dat %>%
#   select(url,authors) %>%
#   unnest(cols = authors) %>%
#   select(-authors) %>%
#   rename(authors=name) %>%
#   mutate(authors = authors %>% str_remove("PROPOS RECUEILLIS PAR "),
#          authors = authors %>% str_remove("^PAR "),
#          authors = authors %>% str_to_title())
# 
# authorsdb %>% glimpse
# 
# dat <- dat %>%
#   select(-authors) %>%
#   left_join(authorsdb, by = "url")

# No authors to save here
dat <- dat %>% select(-authors)

# There is an issue with dates: it is sometimes equal to 0001-01-01
# When it is the case, we pick it from the url 

dat <- dat %>% 
  mutate(daturl = url %>% str_extract("\\d{4}/\\d{2}/\\d{2}") %>% 
           lubridate::ymd(),
         date = date %>% lubridate::as_date(),
         date = if_else(date < "1000-01-01", daturl,date)) %>% 
  select(-daturl)


dat %>% glimpse
dat %>% count(!is.na(date))
dat %>% count(date < "1980-01-01")

# Keep only non-missing date
dat <- dat %>% filter(!is.na(date))

# Filter europ brexit
dat <- dat %>% filter(str_detect(str_to_lower(title), "europ|brexit") |
                        str_detect(str_to_lower(body), "europ|brexit"))


# Check number of observations and duplicates on url
dat %>% glimpse
dat %>% select(url) %>% distinct() %>% dim()

# Keep only one instance per duplicated url 
dat <- dat %>% 
  group_by(url) %>% 
  arrange(desc(nchar(body))) %>% 
  filter(row_number()==1) %>% 
  ungroup() 

dat %>% glimpse

# Save the data
dat %>%
  write_rds(here("data","clean_newspapers","publico.rds"))

