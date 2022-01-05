## master for the analysis phase

# Match article words with polarity lexicons
source(here::here("analysis","polarity.R"))
# Match article words with list of countries
source(here::here("analysis","search_countries.R"))
# Summary stats
rmarkdown::render(here::here("analysis","summary_stats.Rmd"))

# Events and number of articles
rmarkdown::render(here::here("analysis","news_events.Rmd"))

# Parse news articles using Spacy 
# French articles
source(here::here("analysis","parse_spacy_fr.R"))
# Italian articles
source(here::here("analysis","parse_spacy_it.R"))
# Spanish articles
source(here::here("analysis","parse_spacy_es.R"))
# Spanish articles
source(here::here("analysis","parse_spacy_pt.R"))

# Perform LDA on parsed articles
source(here::here("analysis","lda_estimation.R"))

## At this stage, one needs to manually code the LDA topics in
## here::here("data","lda_topic_manual_labelling")
## Afterwards, one can run the following scripts

# LDA analysis
rmarkdown::render(here::here("analysis","lda_analysis.Rmd"))
