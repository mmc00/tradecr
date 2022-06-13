from multiprocessing.connection import wait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium.common.exceptions import TimeoutException
from selenium.common.exceptions import WebDriverException
import time
import os

# source
## https://stackoverflow.com/questions/45653801/selenium-wait-for-element-to-be-clickable-not-working

## custom function for waiting to be clickable
def wait_for_element_to_be_clickable(browser, selector, timeout=10):
    wd_wait = WebDriverWait(browser, timeout)

    value = wd_wait.until(
        EC.element_to_be_clickable(selector),
        message="waiting for element to be clickable",
    )
    print("WAITING")
    return value


## custom function for clickable wait function that relies on exceptions. """
def custom_wait_clickable_and_click(
    driver, selector, item_name, attempts=5, t4wait=10, tout=10
):
    print("Trying to click: " + item_name)
    count = 0
    while count < attempts:
        try:
            time.sleep(t4wait)

            # This will throw an exception if it times out, which is what we want.
            # We only want to start trying to click it once we've confirmed that
            # selenium thinks it's visible and clickable.
            elem = wait_for_element_to_be_clickable(driver, selector, timeout=tout)
            elem.click()
            return elem

        except WebDriverException as e:
            if "is not clickable at point" in str(e):
                print("Retrying clicking on button.")
                count = count + 1
            else:
                raise e

    raise TimeoutException("custom_wait_clickable timed out" + item_name)


## function for checking if the file was donwloaded
### source
# https://stackoverflow.com/questions/34338897/python-selenium-find-out-when-a-download-has-completed
def download_wait(directory, timeout, nfiles=None):
    """
    Wait for downloads to finish with a specified timeout.

    Args
    ----
    directory : str
        The path to the folder where the files will be downloaded.
    timeout : int
        How many seconds to wait until timing out.
    nfiles : int, defaults to None
        If provided, also wait for the expected number of files.

    """
    seconds = 0
    dl_wait = True
    while dl_wait and seconds < timeout:
        time.sleep(1)
        dl_wait = False
        files = os.listdir(directory)
        print(files)
        if nfiles and len(files) != nfiles:
            dl_wait = True

        for fname in files:
            if fname.endswith(".crdownload"):
                dl_wait = True

        seconds += 1
    return seconds
