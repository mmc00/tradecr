# coding=utf-8
from selenium import webdriver
import time
import os

download_path = os.getenv('TEMP_PATH')
driver_path = os.getenv('DRIVER_PATH')
print(os.getenv('TEMP_PATH'))
print(os.getenv('DRIVER_PATH'))
os.chmod(driver_path, 07550o)

options = webdriver.ChromeOptions()
prefs = {"download.default_directory" : download_path}
options.add_experimental_option("prefs",prefs)
browser = webdriver.Chrome(driver_path, options=options)

# start browsing
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
# Country
pais = browser.find_element_by_id('ASPxRoundPanel2_CBPais_S_D')
pais.click()
time.sleep(1)
# Check years
## check years
years = browser.find_element_by_id('ASPxPivotGrid1_sortedpgHeader5F')
years.click()
time.sleep(1)
## select all years
allyears = browser.find_element_by_id('ASPxPivotGrid1FTRIAll')
allyears.click()
time.sleep(1)
## apply changes
appyears = browser.find_element_by_id('ASPxPivotGrid1_FPWOK_B')
appyears.click()
# download
downloadclick = browser.find_element_by_id('ASPxRoundPanel3_ImageButton3')
downloadclick.click()
time.sleep(1)
# close
browser.close()
