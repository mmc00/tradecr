# functions.R
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
get_etag <- function(site = server_call, path_sharepoint = obj_download) {
  call_site <- site$get_item_properties(path_sharepoint)
  call_site$eTag
}
# descargar archivos del sharepoint
download_xls <- function(site, path_sharepoint, path_destiny,
                         etag = 0) {
  print(etag)
  site$download_file(path_sharepoint,
    dest = path_destiny,
    overwrite = T
  )
  path_destiny
}
## leer diccionario
reading_dict <- function(path) {
  read_excel(path,
    sheet = "CodNombr",
    .name_repair = "minimal"
  ) %>%
    select(1:2) %>%
    set_names(c("code_pais2", "nombre")) %>%
    mutate(code_pais2 = as.numeric(code_pais2))
}
## descargar efectiva del diccionario
effective_download <- function(server, url, path, etag) {
  download_xls(
    server,
    url,
    path_destiny = path,
    etag = etag
  )
  return(path)
}

