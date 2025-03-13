from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from scraper.retry_logic import retry_request

def scrape_dynamic_website(url):
    options = Options()
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    
    driver_path = ChromeDriverManager().install()
    driver = webdriver.Chrome(driver_path, options=options)
    driver.get(url)

    elements = driver.find_elements("tag name", "h2")
    data = elements[0].text if elements else "No title found"
    driver.quit()

    return {"scraped_data": data}
