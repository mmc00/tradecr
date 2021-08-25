# _targets.R
library(targets)
library(tarchetypes)
library(here)

## setting path
if (xfun::is_windows()) {
  here::i_am("targets.R")
} else {
  here::i_am("tradecr/_targets.R")
}
sapply(list.files(here("R"), full.names = T), source)
options(tidyverse.quiet = TRUE)
tar_option_set(packages = c(
  "tidyverse",
  "here",
  "httr",
  "xml2",
  "XML",
  "readxl",
  "lubridate"
))
# debug = "chrome_version") # add packages here
# params
download_path <- normalizePath(here("temp"))
temp_path <- here("temp")
dir.create(temp_path, showWarnings = F)
# flow
list(
  # path for files
  tar_target(
    temp.condata.path,
    list.files(here("temp")) %>%
      str_subset(., "con_data") %>%
      here("temp", .),
    format = "file"
  ),
  tar_target(
    temp.capdata.path,
    list.files(here("temp")) %>%
      str_subset(., "cap_data") %>%
      here("temp", .),
    format = "file"
  ),
  # reshape
  tar_target(
    temp.condata.long,
    long_country_data(temp.condata.path)
  ),
  tar_target(
    temp.capdata.long,
    long_chapter_data(temp.capdata.path)
  ),
  # adding to dataset
  tar_target(
    appending.condata,
    append_data(
      temp.condata.long,
      "historical_country_data_procomer.csv"
    ),
    format = "file"
  ),
  tar_target(
    appending.capdata,
    append_data(
      temp.capdata.long,
      "historical_chapter_data_procomer.csv"
    ),
    format = "file"
  ),
  # reading last data
  tar_target(
    old.data,
    reading_old_data(
      here(
        "data",
        "historical_chapter_data_procomer.csv"
      ),
      appending.capdata
    )
  ),
  tar_target(
    sort.old.data,
    last_old_data(old.data, appending.capdata)
  ),
  tar_target(
    sort.new.data,
    last_new_data(temp.capdata.long)
  ),
  tar_target(
    compare.agg.data,
    comparing_data(
      sort.new.data,
      sort.old.data
    )
  )
)
