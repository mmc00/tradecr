# functions.R
library(Microsoft365R)
# activar sharepoint
activate_sharepoint_site <- function(page_url) {
  ## Se usa el paquete "Microsoft365R
  ## si es la primera vez que se usa
  ## se loguea mediante get_sharepoint_site()
  ## si da error hay que solicitar permiso TI (Alfonso)
  ## si se cambio de contraseña se utiliza el comando
  ## AzureAuth::clean_token_directory()
  site <- get_sharepoint_site(site_url = page_url)
  # obtenemos folder
  drv <- site$get_drive()
}
# obtener el etag (para ver si el archivo cambia)
get_etag <- function(site = server_call, path_sharepoint = obj_download){
  call_site <- site$get_item_properties(path_sharepoint)
  call_site$eTag
}
# descargar archivos del sharepoint
download_xls <- function(site, path_sharepoint, path_destiny,
                         etag = 0){
  print(etag)
  site$download_file(path_sharepoint,
  dest = path_destiny,
  overwrite = T
)
  path_destiny
}


server.call <- activate_sharepoint_site("https://comexcr.sharepoint.com/Monitoreo/")

dict_link <- read_delim("input/sicomex_dict_path_sharepoint.txt",
  escape_backslash = TRUE,
  delim = ","
) %>%
  pull(file)

dict_etag <- get_etag(
  site = server.call,
  path_sharepoint = dict_link
)

dict_down <- download_xls(
  server.call,
  dict_link,
  path_destiny = "input/dict_sicomex.xlsx",
  etag = dict_etag
)
# 
# 
# 
#   tar_target(
#     server.call,
#     activate_sharepoint_site("https://comexcr.sharepoint.com/Monitoreo/")
#   ),
# 
#   ## descargamos el diccionario para arreglar paises
#   tar_target(
#     sicomex.path,
#     read_delim("input/sicomex_dict_path_sharepoint.txt",
#       escape_backslash = TRUE,
#       delim = ","
#     ) %>%
#       pull(file)
#   ),
#   tar_target(
#     tag.sicomex,
#     get_etag(
#       site = server.call,
#       path_sharepoint = sicomex.path
#     )
#   ),
#   tar_target(
#     download.sicomex.dict,
#     download_xls(
#       server.call,
#       sicomex.path,
#       path_destiny = paste0(main_path, "/input/dict_sicomex.xlsx"),
#       etag = tag.sicomex
#     ),
#     format = "file"
#   ),
#   ## cargamos el diccionario
#   tar_target(
#     dict.sicomex,
#     read_excel(download.sicomex.dict,
#       sheet = "CodNombr"
#     ) %>%
#       select(1:2) %>%
#       set_names(c("code_pais", "pais")) %>%
#       mutate(code_pais = as.numeric(code_pais))
#   ),