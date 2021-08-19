procomer_country <- function(url, download_path_var, version_driver) {

  ## folder
  eCaps <- list(
    chromeOptions =
      list(prefs = list(
        "download.default_directory" = download_path_var
      ))
  )

  ## Version of chrome driver
  # vers <- binman::list_versions("chromedriver") %>%
  #   unname() %>%
  #   unlist()
  # drivern <- length(vers) - 1

  ## set driver
  driver <- RSelenium::rsDriver(
    # chromever = vers[drivern],
    chromever = version_driver,
    port = 4562L, extraCapabilities = eCaps
  )

  ## set client
  remote_driver <- driver[["client"]]
  remote_driver$open()
  remote_driver$navigate(url)

  ## clicks
  ### Manual 6
  address_element <-
    remote_driver$findElement(
      using = "id",
      value = "ASPxRoundPanel2_RBValorST"
    )
  address_element$clickElement()
  Sys.sleep(3)


  ### Region
  address_element <-
    remote_driver$findElement(
      using = "id",
      value = "ASPxRoundPanel2_CBRegion"
    )
  address_element$clickElement()
  Sys.sleep(3)
  ### Pais
  address_element2 <-
    remote_driver$findElement(
      using = "id",
      value = "ASPxRoundPanel2_CBPais_S_D"
    )
  address_element2$clickElement()
  Sys.sleep(2)


  ### Selección de años
  #### casilla de años
  address_element <-
    remote_driver$findElement(
      using = "id",
      value = "ASPxPivotGrid1_sortedpgHeader5F"
    )
  address_element$clickElement()
  Sys.sleep(2)
  #### todos los años
  address_element <-
    remote_driver$findElement(
      using = "id",
      value = "ASPxPivotGrid1FTRIAll"
    )
  address_element$clickElement()
  Sys.sleep(2)
  #### aplicar cambios
  address_element <-
    remote_driver$findElement(
      using = "id",
      value = "ASPxPivotGrid1_FPWOK_B"
    )
  address_element$clickElement()
  Sys.sleep(3)

  ### descarga
  address_element <-
    remote_driver$findElement(
      using = "id",
      value = "ASPxRoundPanel3_ImageButton3"
    )
  address_element$clickElement()
  Sys.sleep(2)

  ### removemos
  remote_driver$close()
  driver$client$quit()
  rm(driver)
  gc()
  system("taskkill /im java.exe /f", intern = FALSE, ignore.stdout = FALSE)

  #### path
  path_return <- paste0(download_path, "\\", "PivotGrid.xls")

  return(path_return)
}
