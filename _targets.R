# _targets.R
library(targets)
library(tarchetypes)
library(here)
sapply(list.files(here("R"), full.names = T), source)
options(tidyverse.quiet = TRUE)
tar_option_set(packages = c("tidyverse",
                            "RSelenium",
                            "here",
                            "httr",
                            "xml2",
                            "XML")) # add packages here
# params 
download_path <- normalizePath(here("temp"))
# flow
list(
  ## enlace
  tar_target(
    exports_link,
    "http://sistemas.procomer.go.cr/estadisticas/inicio.aspx"
  ),
  ## temporal data by country
  tar_target(
    temp_country,
    procomer_country(exports_link, download_path)
  )
)
