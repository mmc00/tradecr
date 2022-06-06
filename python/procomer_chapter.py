# coding=utf-8
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
import os

# enviroment vars
download_path = os.getenv("TEMP_PATH")
driver_path = os.getenv("DRIVER_PATH")

# selenium options
options = webdriver.ChromeOptions()
prefs = {"download.default_directory": download_path}
options.add_experimental_option("prefs", prefs)
options.add_argument("--remote-debugging-port=9222")
options.add_argument("--no-sandbox")
options.add_argument("--window-size=1420,1080")
options.add_argument("--headless")
options.add_argument("--disable-dev-shm-usage")
options.add_argument("--disable-gpu")
options.add_argument("--disable-notifications")
ser = Service(driver_path)
options.add_experimental_option("useAutomationExtension", False)

# driver call
browser = webdriver.Chrome(service=ser, options=options)

# parameters dict
## for wait element call
args = {"driver": browser, "attempts": 5, "t4wait": 5, "tout": 5}
## wait for downloaded file check
time_constant = 10

# functions
from helpers import *


# start browsing
browser.get("http://sistemas.procomer.go.cr/estadisticas/inicio.aspx")

# apply manual 6
custom_wait_clickable_and_click(
    selector=(By.ID, "ASPxRoundPanel2_RBValorST"), item_name="manual6", **args
)

# removing region
custom_wait_clickable_and_click(
    selector=(By.ID, "ASPxRoundPanel2_CBRegion"), item_name="region", **args
)

# apply chapter
custom_wait_clickable_and_click(
    selector=(By.ID, "ASPxRoundPanel2_CBPartida"), item_name="chapter", **args
)

# years
## check years box
custom_wait_clickable_and_click(
    selector=(By.ID, "ASPxPivotGrid1_sortedpgHeader5F"),
    item_name="checkbox_year",
    **args
)

## select all years
custom_wait_clickable_and_click(
    selector=(By.ID, "ASPxPivotGrid1FTRIAll"), item_name="all_years", **args
)

## apply changes
custom_wait_clickable_and_click(
    selector=(By.ID, "ASPxPivotGrid1_FPWOK_B"), item_name="apply_years", **args
)

# download
custom_wait_clickable_and_click(
    selector=(By.ID, "ASPxRoundPanel3_ImageButton3"), item_name="download_click", **args
)

## check if file was downloaded
download_wait(download_path, time_constant)

# close
browser.close()
browser.quit()
