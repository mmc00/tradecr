# coding=utf-8
from selenium import webdriver
import time
import os

download_path = os.getenv('TEMP_PATH')
driver_path = os.getenv('DRIVER_PATH')
print(os.getenv('TEMP_PATH'))
print(os.getenv('DRIVER_PATH'))

options = webdriver.ChromeOptions()
prefs = {"download.default_directory" : download_path}
options.add_experimental_option("prefs",prefs)
