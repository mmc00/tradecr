# coding=utf-8
from selenium import webdriver
import time
import os

download_path = os.getenv('TEMP_PATH')
driver_path = os.getenv('DRIVER_PATH')
# download_path = "D:\\tradecr\\temp"
# driver_path = "D:\chromedriver_win32\chromedriver.exe"
options = webdriver.ChromeOptions()
type(download_path)
prefs = {"download.default_directory" : download_path}
