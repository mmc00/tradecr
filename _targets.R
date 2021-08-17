# _targets.R
library(targets)
library(tarchetypes)
source("R/functions.R")
options(tidyverse.quiet = TRUE)
tar_option_set(packages = c("tidyverse",
                            "RSelenium",
                            "here",
                            "httr",
                            "xlm2"
                            "XML")) # add packages here

tar_pipeline(

  # add targets here

)
