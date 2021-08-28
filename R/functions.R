getting_temps <- function(folder, name, dummy) {
  list.files(folder) %>%
    str_subset(., name) %>%
    paste0(folder, "/", .)
}

long_country_data <- function(patho, dummy) {
  data <- read_excel(path = patho) %>%
    rename("country" = "...1") %>%
    # fixing uk
    mutate(
      country =
        if_else((country == "Reino Unido-No UE" | country == "Reino Unido-UE"),
          "Reino Unido", country
        )
    ) %>%
    # removing total
    filter(country != "Grand Total") %>%
    select(country, any_of(paste0(1990:2100))) %>%
    slice(-c(1:2)) %>%
    pivot_longer(-country, names_to = "year") %>%
    group_by(country, year) %>%
    summarise(value = sum(value, na.rm = T), .groups = "drop") %>%
    mutate(time = now())

  return(data)
}

long_chapter_data <- function(path) {
  # primera columna mal
  data <- read_excel(path) %>%
    rename("chapter" = "...1") %>%
    filter(chapter != "Grand Total") %>%
    select(chapter, any_of(paste0(1990:2100))) %>%
    slice(-1) %>%
    pivot_longer(-chapter, names_to = "year") %>%
    group_by(chapter, year) %>%
    summarise(value = sum(value, na.rm = T), .groups = "drop") %>%
    mutate(time = now())

  return(data)
}

check_if_exist <- function(name) {
  relative_path <- paste0("data", "/", name)
  file.exists(relative_path)
}

append_data <- function(data, name, dummy = NULL) {
  relative_path <- paste0("data", "/", name)
  print(file.exists(relative_path))
  if (file.exists(relative_path)) {
    write.table(data, file = relative_path, append = T, row.names = F)
  } else {
    write.csv(data, file = relative_path, row.names = F)
  }
  return(relative_path)
}

reading_old_data <- function(path, dummy) {
  if (dummy) {
    read.csv(path)
  } else {
    dummy
  }
}

last_old_data <- function(data, dummy = NULL) {
  if (!(is.logical(data) & !data)) {
    id_date <- data %>%
      mutate(time = lubridate::as_date(time)) %>%
      mutate(
        id_year = year(time),
        id_month = month(time),
        id_day = day(time),
        id_hour = hour(time),
        id_min = minute(time),
        id_sec = second(time)
      ) %>%
      arrange(
        id_year, id_month, id_day,
        id_hour, id_min, id_sec
      ) %>%
      slice(1) %>%
      pull(time)

    data <- data %>%
      filter(time %in% id_date) %>%
      group_by(year) %>%
      summarise(value_old = sum(value, na.rm = T), .groups = "drop")
  } else {
    data <- FALSE
  }
  return(data)
}

last_old_data_month <- function(data, dummy = NULL) {
  if (!(is.logical(data) & !data)) {
    id_date <- data %>%
      mutate(time = lubridate::as_date(time)) %>%
      mutate(
        id_year = year(time),
        id_month = month(time),
        id_day = day(time),
        id_hour = hour(time),
        id_min = minute(time),
        id_sec = second(time)
      ) %>%
      arrange(
        id_year, id_month, id_day,
        id_hour, id_min, id_sec
      ) %>%
      slice(1) %>%
      pull(time)

    data <- data %>%
      filter(time %in% id_date) %>%
      group_by(year, month) %>%
      summarise(value_old = sum(value, na.rm = T), .groups = "drop")
  } else {
    data <- FALSE
  }
  return(data)
}

last_new_data <- function(data) {
  data <- data %>%
    group_by(year) %>%
    summarise(value = sum(value, na.rm = T), .groups = "drop")

  return(data)
}

last_new_data_month <- function(data) {
  data <- data %>%
    group_by(year, month) %>%
    summarise(value = sum(value, na.rm = T), .groups = "drop")

  return(data)
}

comparing_data <- function(new, old, tol = 0.0001) {
  if (!(is.logical(old) & !old)) {
    data <- full_join(new %>%
      mutate(year = as.numeric(year)),
    old %>%
      mutate(year = as.numeric(year)),
    by = "year"
    ) %>%
      mutate(check = abs(value - value_old) <= tol) %>%
      filter(!check)
  } else {
    data <- new %>%
      mutate(value_old = value) %>%
      mutate(check = abs(value - value_old) <= tol) %>%
      filter(!check)
  }

  write.csv(data, "data/check_procomer.csv", row.names = F)
  return("data/check_procomer.csv")
}

comparing_data_month <- function(new, old, tol = 0.0001) {
  if (!(is.logical(old) & !old)) {
    data <- full_join(new %>%
      mutate(year = as.numeric(year)) %>%
      mutate(month = as.numeric(month)),
    old %>%
      mutate(year = as.numeric(year)) %>%
      mutate(month = as.numeric(month)),
    by = c("year", "month")
    ) %>%
      mutate(check = abs(value - value_old) <= tol) %>%
      filter(!check)

    write.csv(data, "data/check_bccr.csv", row.names = F)
  } else {
    data <- new %>%
      mutate(value_old = value) %>%
      mutate(check = abs(value - value_old) <= tol) %>%
      filter(!check)
  }
  return("data/check_bccr.csv")
}

bccr_imp0_api <- function(user, password,
                          start_date, end_date) {
  base <- "https://gee.bccr.fi.cr/Indicadores/Suscripciones/WS/wsindicadoreseconomicos.asmx/ObtenerIndicadoresEconomicos?"
  qr <- list(
    Indicador = "1993",
    FechaInicio = start_date,
    FechaFinal = end_date,
    Nombre = "Marlon",
    Subniveles = "S",
    CorreoElectronico = user,
    Token = password
  )
  res <- GET(base, query = qr)
  dat <- as_list(read_xml(res))

  dat2 <- as_tibble(dat) %>%
    unnest_wider(DataSet) %>%
    unnest(cols = names(.)) %>%
    unnest_wider(Datos_de_INGC011_CAT_INDICADORECONOMIC) %>%
    select(-element) %>%
    filter(NUM_VALOR != "NULL") %>%
    map(unlist) %>%
    bind_cols() %>%
    mutate(DES_FECHA = substr(DES_FECHA, 1, 10)) %>%
    mutate(DES_FECHA = as.Date(DES_FECHA)) %>%
    mutate(NUM_VALOR = as.numeric(NUM_VALOR)) %>%
    mutate(id_month = lubridate::month(DES_FECHA)) %>%
    mutate(id_year = lubridate::year(DES_FECHA))

  return(dat2)
}

getting_agg_imports <- function(data, study_month,
                                study_year) {
  new_data <- data %>%
    filter(id_month == study_month | id_year == study_year) %>%
    select(-DES_FECHA, -COD_INDICADORINTERNO) %>%
    rename(
      "value" = "NUM_VALOR",
      "year" = "id_year",
      "month" = "id_month"
    ) %>%
    mutate(time = now())
}