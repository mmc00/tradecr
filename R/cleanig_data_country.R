cleanig_data_country <- function(pathtemp, dict) {
  # reading data
  data <- read_excel(pathtemp) %>%
    slice(-2, -1) %>%
    rename("nombre" = "...1") %>%
    mutate(code_pais = countryname(nombre, "iso3n")) %>%
    select(nombre, code_pais, everything()) %>%
    filter(!(nombre %in% c(
      "Zona Canal Panamá",
      "Zona Libre Colón",
      "Zona Libre Puerto Cortés",
      "Grand Total"
    )))

  # fixing countries
  data2 <- data %>%
    left_join(pais_dict, by = "nombre") %>%
    mutate(code_pais = if_else(is.na(code_pais),
      code_pais2,
      code_pais
    )) %>%
    mutate(code_pais = case_when(
      nombre == "Kirguistan" ~ 417,
      nombre == "Reino Unido-UE" ~ 826,
      nombre == "Islas de Ultramar Menores de Estados Unidos" ~ 999,
      TRUE ~ code_pais
    ))

  # fixing scale and filter years
  data_long <- data2 %>%
    select(-code_pais2) %>%
    pivot_longer(-c(nombre, code_pais),
      names_to = "year",
      values_to = "valor"
    ) %>%
    filter(year >= 2000) %>%
    mutate(valor = if_else(is.na(valor), 0, valor)) %>%
    mutate(valor = valor * 1000)

  return(data_long)
}
