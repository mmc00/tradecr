# coding=utf-8
from selenium import webdriver
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
import time
import os

download_path = os.getenv('TEMP_PATH')
driver_path = os.getenv('DRIVER_PATH')

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

# constants for time
wait4 = 20
wtime = 10
time_constant = 2

# start browsing
browser.get("http://sistemas.procomer.go.cr/estadisticas/inicio.aspx")

# apply manual 6
manual6 = WebDriverWait(browser, wait4).until(EC.element_to_be_clickable((By.ID, 'ASPxRoundPanel2_RBValorST')))
manual6.click()
region=''
while not region:
    try:
        region = WebDriverWait(browser, wait4).until(EC.element_to_be_clickable((By.ID, 'ASPxRoundPanel2_CBRegion')))
        region.click()
    except:continue

capitulo=''
while not capitulo:
    try:
        capitulo = WebDriverWait(browser, wait4).until(EC.element_to_be_clickable((By.ID, 'ASPxRoundPanel2_CBPartida')))
        capitulo.click()
    except:continue

# Check years
wait = WebDriverWait(browser, wtime)
wait.until(EC.staleness_of(capitulo))
## check years
years=''
while not years:
    try:
        years = WebDriverWait(browser, wait4).until(EC.element_to_be_clickable((By.ID, 'ASPxPivotGrid1_sortedpgHeader5F')))
        years.click()
    except:continue
## select all years
allyears=''
while not allyears:
    try:
        allyears = WebDriverWait(browser, wait4).until(EC.element_to_be_clickable((By.ID, 'ASPxPivotGrid1FTRIAll')))
        allyears.click()
    except:continue
## apply changes
apply_ch=''
while not apply_ch:
    try:
        apply_ch = WebDriverWait(browser, wait4).until(EC.element_to_be_clickable((By.ID, 'ASPxPivotGrid1_FPWOK_B')))
        apply_ch.click()
        browser.implicitly_wait(wait4)
    except:continue

time.sleep(wait4)
# download
downloadclick=''
while not downloadclick:
    try:
        downloadclick = WebDriverWait(browser, wait4).until(EC.element_to_be_clickable((By.ID, 'ASPxRoundPanel3_ImageButton3')))
        downloadclick.click()
        browser.implicitly_wait(wait4)
        wait.until(EC.staleness_of(downloadclick))
    except:continue
## check if file was donwloaded 
while any([filename.endswith(".crdownload") for filename in download_path]):
    try:
        time.sleep(time_constant)
    except:continue
# close
browser.close()
browser.quit()
