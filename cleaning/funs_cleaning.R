#we create a function that reads json (from the .net tool) and creates df
dennisjson_to_df <- function(fil,outlet){
  here("data","scraped_newspapers",outlet,"dennis",fil) %>% 
    jsonlite::fromJSON() %>% 
    mutate(#authors = bind_rows(authors)[,1],
      query = bind_rows(query)[,1]) %>% 
    janitor::clean_names() %>% 
    mutate(section = tolower(section),
           date = lubridate::ymd_hms(date)) %>%  
    filter(text != "") %>% # Remove empty text
    distinct()
}
dennisjson_to_df_safe <- dennisjson_to_df %>% possibly(otherwise = NULL)



#we create a function that reads factiva and creates df
factiva_to_df <- function(fil,outlet){
  here("data","scraped_newspapers",outlet,"factiva",fil) %>% 
    newspapers::import_factiva() %>% 
    mutate(date_en = date %>% lubridate::dmy(), 
           date_fr = date %>% lubridate::dmy(locale = "fr_fr"), 
           date = if_else(is.na(date_en), date_fr, date_en), 
           language = "fr") %>% 
    select(
      newspaper=source,
      language,
      date, 
      title=head, 
      body,
      section
    ) %>%  
    filter(body != "") %>% # Remove empty text
    distinct()
}
factiva_to_df_safe <- factiva_to_df %>% possibly(otherwise = NULL)
