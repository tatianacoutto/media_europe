## 
## Gather clean data
## 
## Takes as input the data cleaned in previous steps (newspaper by newspaper)
## 
## Roland
##
## December 2021
## 


library(tidyverse)
library(here)

source(here("cleaning","funs_cleaning.R"))

## Le Monde
dat <- here("data","clean_newspapers","lemonde.rds") %>% read_rds() %>% 
  ## Le Figaro
  bind_rows(
    here("data","clean_newspapers","figaro.rds") %>% read_rds()
  ) %>% 
  ## La Repubblica
  bind_rows(
    here("data","clean_newspapers","repubblica.rds") %>% read_rds()
  ) %>% 
  ## Corriere
  bind_rows(
    here("data","clean_newspapers","corriere.rds") %>% read_rds()
  ) %>% 
  ## El Mundo
  bind_rows(
    here("data","clean_newspapers","elmundo.rds") %>% read_rds() 
  ) %>% 
  ## El Pais
  bind_rows(
    here("data","clean_newspapers","elpais.rds") %>% read_rds()
  ) %>% 
  ## Publico
  bind_rows(
    here("data","clean_newspapers","publico.rds") %>% read_rds()
  )

dat <- dat %>% 
  select(url, newspaper, language, date, title, body, subtitle)
  

dat %>% glimpse

dat %>% count(newspaper)

dat %>% 
  group_by(newspaper) %>% 
  skimr::skim()

dat %>% 
  filter(!is.na(date)) %>% 
  write_rds(here::here("data","clean_newspapers","all_newspapers.rds"))

