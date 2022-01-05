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

lexicon <- 
  here::here("data","multilingualsentiment","sentiment-lexicons","negative_words_es.txt") %>% 
  read_delim(col_names = "word", delim = ";") %>% 
  mutate(language = "es", polarity = -1) %>% 
  bind_rows(
    here::here("data","multilingualsentiment","sentiment-lexicons","negative_words_fr.txt") %>% 
      read_delim(col_names = "word", delim = ";") %>% 
      mutate(language = "fr", polarity = -1) 
  ) %>%  
  bind_rows(
    here::here("data","multilingualsentiment","sentiment-lexicons","negative_words_it.txt") %>% 
      read_delim(col_names = "word", delim = ";") %>% 
      mutate(language = "it", polarity = -1) 
  ) %>%  
  bind_rows(
    here::here("data","multilingualsentiment","sentiment-lexicons","negative_words_pt.txt") %>% 
      read_delim(col_names = "word", delim = ";") %>% 
      mutate(language = "pt", polarity = -1) 
  ) %>%  
  bind_rows(
    here::here("data","multilingualsentiment","sentiment-lexicons","positive_words_es.txt") %>% 
      read_delim(col_names = "word", delim = ";") %>% 
      mutate(language = "es", polarity = 1) 
  ) %>% 
  bind_rows(
    here::here("data","multilingualsentiment","sentiment-lexicons","positive_words_fr.txt") %>% 
      read_delim(col_names = "word", delim = ";") %>% 
      mutate(language = "fr", polarity = 1) 
  ) %>%  
  bind_rows(
    here::here("data","multilingualsentiment","sentiment-lexicons","positive_words_it.txt") %>% 
      read_delim(col_names = "word", delim = ";") %>% 
      mutate(language = "it", polarity = 1) 
  ) %>%  
  bind_rows(
    here::here("data","multilingualsentiment","sentiment-lexicons","positive_words_pt.txt") %>% 
      read_delim(col_names = "word", delim = ";") %>% 
      mutate(language = "pt", polarity = 1) 
  ) 
  
allnews <- here::here("data","clean_newspapers","all_newspapers.rds") %>% read_rds()

news_polarity_title <- allnews %>% 
  select(doc_id, text=title, language) %>% 
  # slice(1:100000) %>% 
  mutate(gps = doc_id %/% 20000) %>% 
  group_by(gps) %>% 
  group_modify(function(df,...){
    df %>% 
      tidytext::unnest_tokens(word, text) %>% 
      inner_join(
        lexicon, by = c("language", "word")
      ) %>% 
      group_by(doc_id) %>% 
      summarise(polarity = mean(polarity)) %>% 
      ungroup()
  }) %>% 
  ungroup() %>% 
  select(-gps) 

news_polarity_title %>% glimpse

news_polarity_title %>% write_rds(here::here("data","output","news_polarity_title.rds"))


## This step takes around 400 sec for 1 million articles
tic()
news_polarity <- allnews %>% 
  select(doc_id, text=body, language) %>% 
  # slice(1:100000) %>% 
  mutate(gps = doc_id %/% 20000) %>% 
  group_by(gps) %>% 
  group_modify(function(df,...){
    df %>% 
      tidytext::unnest_tokens(word, text) %>% 
      inner_join(
        lexicon, by = c("language", "word")
      ) %>% 
      group_by(doc_id) %>% 
      summarise(polarity = mean(polarity)) %>% 
      ungroup()
  }) %>% 
  ungroup() %>% 
  select(-gps) 
toc()

news_polarity %>% glimpse

news_polarity %>% write_rds(here::here("data","output","news_polarity.rds"))

