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
                            "XML",
                            "readxl",
                            "Microsoft365R")) # add packages here
# params 
download_path <- normalizePath(here("temp"))
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
    getChromeDriverVersion(),
    cue = tar_cue_force(TRUE)
  ),
  ## temporal data by country
  tar_target(
    temp_country,
    procomer_country(exports_link, download_path,
                     chrome_version),
    cue = tar_cue_force(TRUE)
  ),
  ## creating server
  tar_target(
    server_call,
    activate_sharepoint_site("https://comexcr.sharepoint.com/Monitoreo/")
  ),
  ## reading path for dict sicomex
  tar_target(
    dict_link,
    read_delim("input/sicomex_dict_path_sharepoint.txt",
      escape_backslash = TRUE,
      delim = ","
    ) %>%
      pull(file)
  ),
  ## checking etag for dict file
  tar_target(
    dict_etag,
    get_etag(
      site = server_call,
      path_sharepoint = dict_link
    ),
    cue = tar_cue_force(TRUE)
  ),
  ## download the file
  tar_target(
    file_dict,
    effective_download(
      server_call,
      dict_link,
      "input/dict_sicomex.xlsx",
      dict_etag
    )
  ),
  ## reading dict data
  tar_target(
    sicomex_dict,
    reading_dict(file_dict)
  )
)
