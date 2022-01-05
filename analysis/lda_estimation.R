## 
## Estimate LDA on parsed news
## 
##
## Based on the parsed newspaper articles
## 
##
## Tatiana Coutto
##
## December 2021
## 

library(tidyverse)
library(text2vec)
library(tictoc)

# Hyper-parameters
ntopic <- 50

# LDA estimation function: language-specific
lda_estimate <- function(lang = "fr") {
  
  # Load data
  parsed <- here::here("data","parsed_newspapers",paste0("parsed_news_",lang,".rds")) %>% 
    read_rds()
  
  ## This is to test before running on the full sample
  # parsed <- parsed %>% slice(1:50000) 
  
  set.seed(1234)
  
  it <- parsed %>% 
    pull(text) %>% 
    tolower() %>% 
    word_tokenizer() %>% 
    itoken(ids = parsed %>% pull(doc_id), progressbar = TRUE)
  
  v <- create_vocabulary(it)
  v <- prune_vocabulary(v, term_count_min = 10, doc_proportion_max = 0.2)
  
  vectorizer <- vocab_vectorizer(v)
  dtm <- create_dtm(it, vectorizer, type = "dgTMatrix")
  
  lda_model <- LDA$new(n_topics = ntopic, doc_topic_prior = 0.1, topic_word_prior = 0.01)
  doc_topic_distr <- 
    lda_model$fit_transform(x = dtm, n_iter = 1000, 
                            convergence_tol = 0.001, n_check_convergence = 25, 
                            progressbar = FALSE)
  

  
  # save the results
  ## document-topic matrix
  doc_topic_distr %>% 
    write_rds(here::here("data","output", paste0("LDA_",lang,"_",ntopic,"_doctop.rds")))
  ## topic-word matrix (plus other stuff)
  lda_model %>% 
    write_rds(here::here("data","output", paste0("LDA_",lang,"_",ntopic,"_model.rds")))
  
  # Export a list of words for each topic for manual coding 
  tibble(topic = paste("topic",1:ntopic,sep=""), 
         topic_name = NA) %>% 
    bind_cols(        
      lda_model$get_top_words(n = 20, topic_number = 1:ntopic, lambda = .3) %>%
        t() %>% 
        magrittr::set_colnames(paste("word",1:20,sep="")) %>% 
        as_tibble() 
    ) %>% 
    write_csv(here::here("data","lda_topic_manual_labelling",
                         paste0("tolabel_lda_",lang,"_",ntopic,".csv")))
  
}

# 2600 sec
tic()
lda_estimate("fr")
toc()

# 2400 sec
tic()
lda_estimate("it")
toc()

# ??? sec
tic()
lda_estimate("es")
toc()

# ??? sec
tic()
lda_estimate("pt")
toc()
