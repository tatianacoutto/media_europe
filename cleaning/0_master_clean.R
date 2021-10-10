## master for the cleaning phase
library(here)

## Run cleaning scripts for each outlet
source(here("cleaning","clean_lemonde.R"))
source(here("cleaning","clean_figaro.R"))
source(here("cleaning","clean_corriere.R"))
source(here("cleaning","clean_repubblica.R"))
source(here("cleaning","clean_elmundo.R"))
source(here("cleaning","clean_elpais.R"))
source(here("cleaning","clean_publico.R"))

## Knit checking script
rmarkdown::render(here("cleaning","check_cleandata.Rmd"))
