# coding=utf-8
from selenium import webdriver
import time
import os

a2 = os.environ['a']
print(a2)

download_path = os.getenv('TEMP_PATH')
driver_path = os.getenv('DRIVER_PATH')
# download_path = "D:\\tradecr\\temp"
# driver_path = "D:\chromedriver_win32\chromedriver.exe"
options = webdriver.ChromeOptions()
typo = type(download_path)
print(typo)
prefs = {"download.default_directory" : download_path}
