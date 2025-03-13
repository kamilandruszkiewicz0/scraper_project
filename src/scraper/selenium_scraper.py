from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from scraper.scraper import is_valid_url

def scrape_dynamic_website(url):
    if not is_valid_url(url):
        return {"statusCode": 400, "body": "Invalid URL format"}

    options = Options()
    options.add_argument("--headless=new")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")

    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)

    driver.get(url)

    elements = driver.find_elements("tag name", "h2")
    data = elements[0].text if elements else "No title found"
    driver.quit()

    return {"statusCode": 200, "scraped_data": data}
