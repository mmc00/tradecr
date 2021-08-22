getChromeDriverVersion <- function(versions = binman::list_versions("chromedriver")) {
  if (xfun::is_unix()) {
    chrome_driver_version <-
      system2(
        command = ifelse(xfun::is_macos(),
          "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
          "google-chrome-stable"
        ),
        args = "--version",
        stdout = TRUE,
        stderr = TRUE
      ) %>%
      stringr::str_extract(pattern = "(?<=Chrome )(\\d+\\.){3}")

    ## on Windows a plattform-specific bug prevents us from calling the Google Chrome binary directly to get its version number
    ## cf. https://bugs.chromium.org/p/chromium/issues/detail?id=158372
  } else if (xfun::is_windows()) {
    chrome_driver_version <-
      system2(
        command = "wmic",
        args = 'datafile where name="C:\\\\Program Files (x86)\\\\Google\\\\Chrome\\\\Application\\\\chrome.exe" get Version /value',
        stdout = TRUE,
        stderr = TRUE
      ) %>%
      stringr::str_extract(pattern = "(?<=Version=)(\\d+\\.){3}")
  } else {
    rlang::abort(message = "Your OS couldn't be determined (Linux, macOS, Windows) or is not supported!")
  }
  print("funcion de driver")
  print(versions)
  # ... and determine most recent ChromeDriver version matching it
  if (length(versions) == 0) {
    chrome_driver_version
    # %>%
      # magrittr::extract(!is.na(.)) %>%
      # stringr::str_replace_all(
      #   pattern = "\\.",
      #   replacement = "\\\\."
      # ) %>%
      # paste0("^", .) %>%
      # # as.numeric_version() %>%
      # max() %>%
      # as.character()
  } else {
    chrome_driver_version %>%
      magrittr::extract(!is.na(.)) %>%
      stringr::str_replace_all(
        pattern = "\\.",
        replacement = "\\\\."
      ) %>%
      paste0("^", .) %>%
      stringr::str_subset(string = dplyr::last(versions)) %>%
      as.numeric_version() %>%
      max() %>%
      as.character()
  }
}

driver_number <- function(port = 4567L, force = FALSE, verbose = FALSE) {
  if (force) {
    rD <- NULL
  }
  if (!is.null(rD)) {
    rD
  }
  versions <- binman::list_versions("chromedriver")
  print("fuera loop")
  print(versions)
  length(versions) == 0
  if (length(versions) == 0) {
    versions <- getChromeDriverVersion()
    print(versions)
    return(versions)
  } else {
    print("hola")
    versions <- c(versions$mac64, getChromeDriverVersion(versions))
    v <- length(versions) + 1
    while (v && (is.null(rD) || cond_val)) {
      rhversion <- versions[v]
      v <- v - 1 # Try each value
      rD <- tryCatch(rsDriver(
        verbose = verbose,
        port = port + sample(0:1000, 1),
        chromever = versions[v],
        geckover = NULL,
        phantomver = NULL
      ),
      error = function(e) e,
      message = function(m) m
      )
      cond_val <- inherits(rD, "condition")
      if (!cond_val) {
        rD[["server"]]$stop()
        rD <- NULL
        try(gc(rD))
      }
      if (.Platform$OS.type == "unix") {
        system("/bin/sh")
        system("killchrome.sh")
        system("kill $(ps aux | grep 'chromedrive[r]' | awk '{print $2}')")
      } else {
        system("taskkill /im java.exe /f", intern = FALSE, ignore.stdout = FALSE)
      }
    }
    return(rhversion)
  }
}