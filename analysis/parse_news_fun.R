## 
## Function: parse news articles using Spacy
## 
## Input: data at the article level with text to parse
## Keep only Noun, Verb, Adj, Adv, Propn and Entities
## Lemmatise 
## Output: data at the article level with lemmas and entities
## 
##
## Tatiana Coutto
##
## December 2021
## 

parse_news <- function(id_txt){
  id_txt %>% 
    spacy_parse() %>% 
    # Keep only nouns, verbs, adjectives, adverbs, prop nouns, 
    #  and entity terms (except from spaces)
    filter((pos %in% c("NOUN","VERB","ADJ","ADV","PROPN"))|
             (entity!=""), 
           pos != "SPACE") %>% 
    mutate(entity_id = ifelse(str_sub(entity,-1,-1)=="I",0,1), 
           entity_id = cumsum(entity_id)) %>%
    group_by(doc_id, entity_id) %>% 
    summarise(lemma = ifelse(n()>1, 
                             paste0(token, collapse="_"),
                             lemma)) %>% 
    ungroup() %>% 
    group_by(doc_id) %>%
    summarise(text = paste0(lemma, collapse=" ")) 
}