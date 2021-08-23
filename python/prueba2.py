# coding=utf-8
from selenium import webdriver
import time
import os

download_path = os.environ['TEMP_PATH']
driver_path = os.environ['DRIVER_PATH']
# download_path = "D:\\tradecr\\temp"
# driver_path = "D:\chromedriver_win32\chromedriver.exe"
options = webdriver.ChromeOptions()
print(download_path)
prefs = {"download.default_directory" : download_path}
