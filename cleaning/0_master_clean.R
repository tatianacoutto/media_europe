## master for the cleaning phase

## Run cleaning scripts for each outlet
source(here::here("cleaning","clean_lemonde.R"))
source(here::here("cleaning","clean_figaro.R"))
source(here::here("cleaning","clean_corriere.R"))
source(here::here("cleaning","clean_repubblica.R"))
source(here::here("cleaning","clean_elmundo.R"))
source(here::here("cleaning","clean_elpais.R"))
source(here::here("cleaning","clean_publico.R"))

## Knit checking script
rmarkdown::render(here::here("cleaning","check_cleandata.Rmd"))

source(here::here("cleaning","gather_data.R"))


