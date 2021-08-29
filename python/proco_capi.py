# coding=utf-8
from selenium import webdriver
import time
import os

download_path = os.getenv('TEMP_PATH')
driver_path = os.getenv('DRIVER_PATH')
# os.chmod(driver_path, 0o7550)
# download_path = "C:\\Documentos\\tradecr\\temp"
# driver_path = "C:\\Users\\Marlon.molina\\AppData\\Local\\binman\\binman_chromedriver\\win32\\92.0.4515.107\\chromedriver.exe"

options = webdriver.ChromeOptions()
prefs = {"download.default_directory" : download_path}
options.add_experimental_option("prefs",prefs)
options.add_argument("--remote-debugging-port=9222")
options.add_argument('--no-sandbox')
options.add_argument('--window-size=1420,1080')
options.add_argument('--headless')
options.add_argument('--disable-dev-shm-usage')
options.add_argument('--disable-gpu')
options.add_argument("--disable-notifications")
options.add_experimental_option('useAutomationExtension', False)
browser = webdriver.Chrome(driver_path, options=options)

# start browsing
browser.get("http://sistemas.procomer.go.cr/estadisticas/inicio.aspx")
time.sleep(6)
# Manual 6
manual6 = browser.find_element_by_id('ASPxRoundPanel2_RBValorST')
manual6.click()
time.sleep(6)
# Region
region = browser.find_element_by_id('ASPxRoundPanel2_CBRegion')
region.click()
time.sleep(6)
# partida
pais = browser.find_element_by_id('ASPxRoundPanel2_CBPartida')
pais.click()
time.sleep(6)
# Check years
## check years
years = browser.find_element_by_id('ASPxPivotGrid1_sortedpgHeader5F')
years.click()
time.sleep(6)
## select all years
allyears = browser.find_element_by_id('ASPxPivotGrid1FTRIAll')
allyears.click()
time.sleep(6)
## apply changes
appyears = browser.find_element_by_id('ASPxPivotGrid1_FPWOK_B')
appyears.click()
time.sleep(6)
# download
downloadclick = browser.find_element_by_id('ASPxRoundPanel3_ImageButton3')
downloadclick.click()
time.sleep(6)
# close
browser.close()
browser.quit()
