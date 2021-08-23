import os
print('current directory')
print(os.getcwd())
print(1+2)

from selenium import webdriver
import time

options = webdriver.ChromeOptions()
prefs = {"download.default_directory" : "D:\\tradecr\\temp"}
options.add_experimental_option("prefs",prefs)

browser = webdriver.Chrome("D:\chromedriver_win32\chromedriver.exe",
chrome_options=options)


browser.get("http://sistemas.procomer.go.cr/estadisticas/inicio.aspx")
time.sleep(1)
# Manual 6
manual6 = browser.find_element_by_id('ASPxRoundPanel2_RBValorST')
manual6.click()
time.sleep(1)
# Region
region = browser.find_element_by_id('ASPxRoundPanel2_CBRegion')
region.click()
time.sleep(1)
# Pais
pais = browser.find_element_by_id('ASPxRoundPanel2_CBPais_S_D')
pais.click()
time.sleep(1)

# Selección de años
## casilla de años
years = browser.find_element_by_id('ASPxPivotGrid1_sortedpgHeader5F')
years.click()
time.sleep(1)
## todos los años
allyears = browser.find_element_by_id('ASPxPivotGrid1FTRIAll')
allyears.click()
time.sleep(1)
## aplicar cambios
appyears = browser.find_element_by_id('ASPxPivotGrid1_FPWOK_B')
appyears.click()

# descarga
downloadclick = browser.find_element_by_id('ASPxRoundPanel3_ImageButton3')
downloadclick.click()
time.sleep(1)

browser.close()