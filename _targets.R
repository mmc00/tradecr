# _targets.R
library(targets)
library(tarchetypes)
library(here)
sapply(list.files(here("R"), full.names = T), source)
options(tidyverse.quiet = TRUE)
tar_option_set(packages = c(
  "tidyverse",
  "RSelenium",
  "here",
  "httr",
  "xml2",
  "XML",
  "readxl",
  "binman",
  "Microsoft365R"
))
# debug = "temp_country") # add packages here
# params
download_path <- normalizePath(here("temp"))
temp_path <- here("temp")
dir.create(temp_path, showWarnings = F)
# flow
list(
  # enlace para Exportaciones
  tar_target(
    exports_link,
    "http://sistemas.procomer.go.cr/estadisticas/inicio.aspx"
  ),
  ## getting chrome version
  tar_target(
    chrome_version,
    driver_number(force = T),
    cue = tar_cue_force(TRUE)
  ),
  ## temporal data by country
  tar_target(
    temp_country,
    procomer_country(
      exports_link, download_path,
      chrome_version
    ),
    cue = tar_cue_force(TRUE)
  ),
  ## clening temp folder
  tar_target(
    cleaning_temp,
    file.remove(list.files(temp_path, full.names = T)),
    cue = tar_cue_force(TRUE)
  )
  # ## download the file
  # tar_target(
  #   file_dict,
  #   effective_download(
  #     server_call,
  #     dict_link,
  #     "input/dict_sicomex.xlsx",
  #     dict_etag
  #   )
  # ),
  # ## reading dict data
  # tar_target(
  #   sicomex_dict,
  #   reading_dict(file_dict)
  # )
)
