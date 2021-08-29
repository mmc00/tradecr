library(httr)
library(XML)
library(tidyverse)
library(xml2)

user_bccr <- Sys.getenv("BCCR_USER")
pass_bccr <- Sys.getenv("BCCR_PASS")
# lista de indicadores
# https://www.bccr.fi.cr/indicadores-economicos/servicio-web/gu%C3%ADa-de-uso

# 3661, Importaciones CIF acumuladas
# 2345, Por principales países (Régimen regular)

base <- "https://gee.bccr.fi.cr/Indicadores/Suscripciones/WS/wsindicadoreseconomicos.asmx/ObtenerIndicadoresEconomicos?"
qr <- list(
  Indicador = "1993",
  FechaInicio = "01/01/1999",
  FechaFinal = "21/12/2021",
  Nombre = "Marlon",
  Subniveles = "S",
  CorreoElectronico = user_bccr,
  Token = pass_bccr
)
res <- GET(base, query = qr)
dat <- as_list(read_xml(res))
# j$DataSet$diffgram$Datos_de_INGC011_CAT_INDICADORECONOMIC
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

dat3 <- dat2 %>%
  filter(id_month == 12 | id_year == 2021) %>%
  select(-id_month, -DES_FECHA, -COD_INDICADORINTERNO) %>%
  rename(
    "value" = "NUM_VALOR",
    "year" = "id_year"
  )

plot(x = dat3$id_year, y = dat3$NUM_VALOR)
