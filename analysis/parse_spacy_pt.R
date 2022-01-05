## 
## Parse news articles from Spanish newspapers
## 
##
## Tatiana Coutto
##
## December 2021
## 

library(here)
library(tidyverse)
library(tictoc)

library(spacyr)


## Start spacyr 
spacy_initialize(model="pt_core_news_sm")

dat <- here::here("data","clean_newspapers","all_newspapers.rds") %>% 
  read_rds() %>% 
  filter(language == "pt")

source(here::here("analysis","parse_news_fun.R"))

dim(dat)[[1]]

## 80 sec for 1000 articles
tic()
parsed <- dat %>% 
  # slice(1:2000) %>% 
  select(doc_id, text=body) %>%
  # mutate(text = text %>% str_remove_all("?|?")) %>%
  # Parse articles using spacy
  mutate(samp = row_number() %/% 1000) %>% 
  split(.$samp) %>% 
  map_dfr(parse_news) 
toc()

parsed %>% glimpse

# Save data
parsed %>% 
  write_rds(here::here("data","parsed_newspapers","parsed_news_pt.rds"))

spacy_finalize()