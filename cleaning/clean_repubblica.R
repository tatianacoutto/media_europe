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
library(jsonlite)
library(here)

# Function to read Repubblica json files
json_to_df <- function(fil){
    print(fil);
    here("data","scraped_newspapers","repubblica","spyder",fil) %>% 
    fromJSON() %>%
    filter(text != "", 
           text %>% tolower() %>% str_detect("europ|brexit")) %>% # Remove empty text
    mutate(section = tolower(section),
           date = lubridate::ymd(date), 
           nchar = nchar(text), 
           page = str_remove(page, "pag. "), 
           section = str_remove(section, "sez. "), 
           body = str_squish(text), 
           title = str_squish(title), 
           author = str_remove(author, "^di "), 
           language = "it") %>%
    select(newspaper, language, date, title, body, section, author, page) %>% 
    distinct() # Remove duplicates
  } 
json_to_df_safe <- json_to_df %>% possibly(otherwise = NULL)

# Read and parse all json files that contain "Repubblica" (no search terms)
dat0 <- list.files(here("data","scraped_newspapers","repubblica","spyder")) %>% 
  str_subset("Repubblica") %>% 
  map_dfr(json_to_df_safe) %>% 
  distinct() # Remove duplicates
  
dat0 %>% glimpse

# Read and parse json files that contain the following terms
dat1 <- list.files(here("data","scraped_newspapers","repubblica","spyder")) %>% 
  str_subset("brexit|europea|UE|juncker") %>% 
  map_dfr(json_to_df_safe) %>% 
  distinct() # Remove duplicates  

dat1 %>% glimpse

# Gather both sources
dat <- dat0 %>% 
  bind_rows(dat1) %>% 
  distinct() 

# Check number of observations and duplicates on url
dat %>% glimpse
dat %>% select(title, date, page) %>% distinct() %>% glimpse

# Check time coverage
dat %>% 
  filter(date > "1985-01-01") %>%
  ggplot(aes(date)) + geom_histogram(binwidth = 24*7) 

# Save the data
dat %>% write_rds(here("data","clean_newspapers","repubblica.rds"))

