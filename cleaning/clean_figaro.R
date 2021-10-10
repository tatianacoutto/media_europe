## 
## Clean data collected on Le Figaro and turn it into rds dataset
## 
## The raw data has been scraped using 
## partly a .NET tool  
## partly some manual collection on Factiva
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


## 1. Data collected with .NET tool

dat <- list.files(here("data","scraped_newspapers","figaro","dennis")) %>% 
  str_subset("json") %>%
  map_dfr(dennisjson_to_df_safe,"figaro") %>% 
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

# Check number of observations and duplicates on url
dat %>% glimpse
dat %>% select(url) %>% distinct() %>% dim()

# Check time coverage
dat %>% 
  filter(date > "1985-01-01") %>%
  ggplot(aes(date)) + geom_histogram(binwidth = 3600*24*7) 


## 2. Data manually collected

mdat <- here("data","scraped_newspapers","figaro","factiva") %>% 
  list.files() %>% 
  str_subset("html") %>%
  map_dfr(factiva_to_df_safe,"figaro") %>% 
  distinct()

# Check number of observations and missing dates
mdat %>% glimpse
mdat %>% count(is.na(date))

# Save the data
dat %>% 
  bind_rows(mdat) %>% 
  write_rds(here("data","clean_newspapers","figaro.rds"))



# ## 3. Other data
# 
# figaro_input <- read_lines(here("data","scraped_newspapers","figaro","other","Figaro_Final.csv"))
# 
# # Special function for this figaro file
# # For every observation:
# # The issue is that the data is comma separated, but there are also 
# #  commas inside the text of the articles 
# # We treat this issue by splitting each line by commas and extracting 
# #  variables before and after the article text
# read_figaro <- function(figaro_line){
#   # Function to reverse character strings
#   strreverse <- function(x){ strsplit(x, NULL) %>% lapply(rev) %>% sapply(paste, collapse="") }
#   
#   c(str_split(figaro_line, ",", n=9)[[1]][1:8], 
#     str_split(figaro_line, ",", n=9)[[1]][9] %>% 
#       strreverse() %>%
#       str_split(",", n=3)%>%
#       pluck(1)%>%
#       strreverse()
#   ) %>%
#     set_names(c("X1","X2","newspaper","date","edition","page_no",
#                 "subtitle","title","id","word_no","body")) %>% 
#     bind_rows()
# }
# 
# # We apply this function to the whole set of articles
# odat <- figaro_input[-1] %>% 
#   map_dfr(read_figaro) %>% 
#   mutate(language = "fr") %>% 
#   select(newspaper, 
#          language, 
#          date, 
#          title, 
#          subtitle, 
#          body, 
#          edition, 
#          page_no
#          ) %>% 
#   # Squish all variables of type character
#   mutate(across(is.character, str_squish)) %>% 
#   # Remote articles with empty bodies
#   filter(body!="") %>% 
#   # Put the date in the right format
#   mutate(date = lubridate::ymd(date))
# 
# # Check number of obs and date  
# odat %>% glimpse
# odat %>% count(is.na(date))
# 
# # Check coverage
# odat %>% 
#   filter(date > "1985-01-01") %>%
#   ggplot(aes(date)) + geom_histogram(binwidth = 24*7) 


