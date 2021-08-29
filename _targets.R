# _targets.R
library(targets)
library(tarchetypes)
library(here)

here::i_am("_targets.R")
sapply(list.files(here("R"), full.names = T), source)
options(tidyverse.quiet = TRUE)
tar_option_set(
  packages = c(
    "tidyverse",
    "here",
    "httr",
    "xml2",
    "XML",
    "readxl",
    "lubridate"
  ),
  debug = "sort.old.data"
) # add packages here
# params
download_path <- normalizePath(here("temp"))
temp_path <- here("temp")
user_bccr <- Sys.getenv("BCCR_USER")
pass_bccr <- Sys.getenv("BCCR_PASS")
# dir.create(temp_path, showWarnings = F)
# flow
list(
  # setting main path
  tar_target(
    main_path,
    here::i_am("_targets.R"),
    cue = tar_cue_force(TRUE)
  ),
  # PROCOMER flow (exports)
  ## path for files
  tar_target(
    temp.condata.path,
    getting_temps("temp", "con_data", main_path),
    format = "file"
  ),
  tar_target(
    temp.capdata.path,
    getting_temps("temp", "cap_data", main_path),
    format = "file"
  ),
  ## reshape
  tar_target(
    temp.condata.long,
    long_country_data(temp.condata.path)
  ),
  tar_target(
    temp.capdata.long,
    long_chapter_data(temp.capdata.path)
  ),
  ## check if data exist
  ### chapter
  tar_target(
    checking.old.chapter.data,
    check_if_exist(
      "data/historical_chapter_data_procomer.csv",
      c("chapter")
    ),
    format = "file"
  ),
  ### country
  tar_target(
    checking.old.country.data,
    check_if_exist(
      "data/historical_country_data_procomer.csv",
      c("country")
    ),
    format = "file"
  ),
  ## reading last data
  tar_target(
    old.data,
    reading_old_data(
      checking.old.chapter.data,
    )
  ),
  ## adding to dataset
  ### chapter
  tar_target(
    appending.condata,
    append_data(
      temp.condata.long,
      checking.old.country.data,
    ),
    format = "file"
  ),
  ### country
  tar_target(
    appending.capdata,
    append_data(
      temp.capdata.long,
      checking.old.chapter.data
    ),
    format = "file"
  ),
  ## sorting data
  tar_target(
    sort.old.data,
    last_old_data(old.data)
  ),
  tar_target(
    sort.new.data,
    last_new_data(temp.capdata.long)
  ),
  ## creating compare data.frame
  tar_target(
    compare.agg.data,
    data_status(
      sort.new.data,
      sort.old.data
    )
  ),
  ## write status data
  tar_target(
    write.status,
    writing_status_frame(
      compare.agg.data,
      "data/status_procomer.csv"
    )
  ),
  ## write checks data
  tar_target(
    write.check,
    writing_check_frame(
      compare.agg.data,
      "data/check_procomer.csv"
    )
  ),
  # BCCR flow (imports)
  ## getting data
  tar_target(
    raw.imp.data,
    bccr_imp0_api(
      user = user_bccr,
      password = pass_bccr,
      start_date = "01/01/1999",
      end_date = "21/12/2021"
    ),
    cue = tar_cue_force(TRUE)
  ),
  ## agregate new data
  tar_target(
    newimp.agg.data,
    getting_agg_imports(raw.imp.data,
      study_month = 12,
      study_year = 2021
    ),
    cue = tar_cue_force(TRUE)
  ),
  ## Check old data
  tar_target(
    checking.old.imp.data,
    check_if_exist(
      "data/historical_imp_data_bccr.csv",
      c("month")
    ),
    format = "file"
  ),
  ## read old data
  tar_target(
    old.imp.data,
    reading_old_data(
      checking.old.imp.data
    ),
  ),
  ## append data
  tar_target(
    appending.impdata,
    append_data(
      newimp.agg.data,
      checking.old.imp.data
    ),
    format = "file"
  ),
  ## sorting data
  tar_target(
    sort.old.imp.data,
    last_old_data_month(old.imp.data)
  ),
  tar_target(
    sort.new.imp.data,
    last_new_data_month(newimp.agg.data)
  ),
  tar_target(
    compare.imp.agg.data,
    data_status_month(
      sort.new.imp.data,
      sort.old.imp.data
    )
  ),
  ## write status data
  tar_target(
    write.imp.status,
    writing_status_frame(
      compare.imp.agg.data,
      "data/status_bccr.csv"
    )
  ),
  ## write checks data
  tar_target(
    write.imp.check,
    writing_check_frame(
      compare.imp.agg.data,
      "data/check_bccr.csv"
    )
  )
)
