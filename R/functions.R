long_country_data <- function(patho, dummy) {
  
  date_dummy <- as.character(as.POSIXct(Sys.time()))
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
    mutate(time = date_dummy)

  return(data)
}

long_chapter_data <- function(path) {
  
  data <- read_excel(path) %>%
    rename("chapter" = "...1") %>%
    filter(chapter != "Grand Total") %>%
    select(chapter, any_of(paste0(1990:2100))) %>%
    slice(-1) %>%
    pivot_longer(-chapter, names_to = "year") %>%
    group_by(chapter, year) %>%
    summarise(value = sum(value, na.rm = T), .groups = "drop") %>% 
    mutate(time = Sys.time())
  
  return(data)
}

append_data <- function(data, name){
  
  relative_path <- paste0("data", "/", name)
  print(relative_path)
  print("ver estado del path")
  print(file.exists(relative_path))
  if (file.exists(relative_path)) {
    write.table(data, file = relative_path, append = T, row.names = F)
  } else{
    print("check si esta dentro de archivo nuevo")
    write.csv(data, file = relative_path, row.names = F)
  }
  return(relative_path)
}

reading_old_data <- function(path, dummy){
  read.csv(path)
}

last_old_data <- function(data, dummy){
  id_date <- data %>%
    # mutate(time = as.POSIXlt(time)) %>% 
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
  
  return(data)
}

last_new_data <- function(data){
   data <- data %>% 
    group_by(year) %>% 
    summarise(value = sum(value, na.rm = T), .groups = "drop")
   
   return(data)
}

comparing_data <- function(new, old, tol = 0.0001) {
  data <- left_join(new %>%
    mutate(year = as.numeric(year)),
  old %>%
    mutate(year = as.numeric(year)),
  by = "year"
  ) %>%
    mutate(check = abs(value - value_old) <= tol) %>%
    filter(!check)

  write.csv(data, "data/check_procomer.csv"), row.names = F)
  return("data/check_procomer.csv")
}

