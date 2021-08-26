library(httr)
library(XML)
library(tidyverse)
library(xml2)

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
  CorreoElectronico = "marlonmolina00@hotmail.com",
  Token = "7L5MCOLMO2"
)
res <- GET(base, query = qr)
dat <- as_list(read_xml(res))
# j$DataSet$diffgram$Datos_de_INGC011_CAT_INDICADORECONOMIC
dat <- as_tibble(dat) %>%
  unnest_wider(DataSet) %>%
  unnest(cols = names(.)) %>%
  unnest_wider(INGC011_CAT_INDICADORECONOMIC) %>%
  select(-element) %>%
  filter(NUM_VALOR != "NULL") %>%
  map(unlist) %>%
  bind_cols() %>%
  mutate(DES_FECHA = substr(DES_FECHA, 1, 10)) %>%
  mutate(DES_FECHA = as.Date(DES_FECHA)) %>%
  mutate(NUM_VALOR = as.numeric(NUM_VALOR))


plot(x = dat$DES_FECHA, y = dat$NUM_VALOR)
