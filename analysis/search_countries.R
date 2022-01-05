## 
## Count number of times countries are mentioned in articles
## 
## For each country, count the number of times it mentions a country in a list
## Used in summary_stats.Rmd
## 
##
## Roland Rathelot
##
## December 2021
## 

library(here)
library(tidyverse)
library(tictoc)

countries <- here::here("data","countries","countries_capitals_fr_it_es_pt_en.xlsx") %>% 
  readxl::read_xlsx(col_names = c("country", "word", "language")) %>% 
  mutate(word = word %>% str_to_lower())

allnews <- here::here("data","clean_newspapers","all_newspapers.rds") %>% read_rds()

## This step takes around 400 sec for 1 million articles
tic()
news_countries <- allnews %>% 
  select(doc_id, text=body, language) %>% 
  # slice(1:100000) %>% 
  mutate(gps = doc_id %/% 20000) %>% 
  group_by(gps) %>% 
  group_modify(function(df,...){
    df %>% 
      tidytext::unnest_tokens(word, text) %>% 
      inner_join(
        countries, by = c("language", "word")
      ) %>% 
      count(doc_id, country)
  }) %>% 
  ungroup() %>% 
  select(-gps) 
toc()

news_countries %>% glimpse

news_countries %>% write_rds(here::here("data","output","news_countries.rds"))

