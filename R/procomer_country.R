procomer_country <- function(url, download_path_var, version_driver) {

  ## folder
  eCaps <- list(
    chromeOptions =
      list(prefs = list(
        "download.default_directory" = download_path_var
      ))
  )
  print(eCaps)
  print(version_driver)
  print(version_driver)
  ## set driver
  print("check-1")
  driver <- RSelenium::rsDriver(
    # chromever = vers[drivern],
    chromever = version_driver,
    port = 4562L, extraCapabilities = eCaps
  )
  print("check0")
  ## set client
  remote_driver <- driver[["client"]]
  remote_driver$open()
  remote_driver$navigate(url)
  print("check1")
  ## clicks
  ### Manual 6
  address_element <-
    remote_driver$findElement(
      using = "id",
      value = "ASPxRoundPanel2_RBValorST"
    )
  address_element$clickElement()
  Sys.sleep(3)
  print("check2")
  ### Region
  address_element <-
    remote_driver$findElement(
      using = "id",
      value = "ASPxRoundPanel2_CBRegion"
    )
  address_element$clickElement()
  Sys.sleep(3)
  print("check3")
  ### Pais
  address_element2 <-
    remote_driver$findElement(
      using = "id",
      value = "ASPxRoundPanel2_CBPais_S_D"
    )
  address_element2$clickElement()
  Sys.sleep(2)
  print("check4")

  ### Selección de años
  #### casilla de años
  address_element <-
    remote_driver$findElement(
      using = "id",
      value = "ASPxPivotGrid1_sortedpgHeader5F"
    )
  address_element$clickElement()
  Sys.sleep(2)
  print("check5")
  #### todos los años
  address_element <-
    remote_driver$findElement(
      using = "id",
      value = "ASPxPivotGrid1FTRIAll"
    )
  address_element$clickElement()
  Sys.sleep(2)
  print("check6")
  #### aplicar cambios
  address_element <-
    remote_driver$findElement(
      using = "id",
      value = "ASPxPivotGrid1_FPWOK_B"
    )
  address_element$clickElement()
  Sys.sleep(3)
  print("check7")
  ### descarga
  address_element <-
    remote_driver$findElement(
      using = "id",
      value = "ASPxRoundPanel3_ImageButton3"
    )
  address_element$clickElement()
  Sys.sleep(2)
  print("check8")
  ### removemos
  remote_driver$close()
  print("check9")
  driver$client$quit()
  print("check10")
  rm(driver)
  print("check11")
  gc()
  print("check12")
  system("taskkill /im java.exe /f", intern = FALSE, ignore.stdout = FALSE)
  print("check13")
  #### path
  path_return <- paste0(download_path, "\\", "PivotGrid.xls")
  print("check14")
  return(path_return)
}
