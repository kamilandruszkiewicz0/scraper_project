import requests
from bs4 import BeautifulSoup
from scraper.retry_logic import retry_request
from scraper.proxy_manager import get_headers, get_proxy
from scraper.selenium_scraper import scrape_dynamic_website  

def scrape_website(url, mode="static"):
    if mode == "dynamic":
        return scrape_dynamic_website(url)

    headers = get_headers()
    response = retry_request(lambda: requests.get(url, headers=headers, timeout=10, proxies=get_proxy()))

    if not response:
        return {"error": "Failed to fetch data"}

    soup = BeautifulSoup(response.text, 'html.parser')
    data = {
        "titles": [item.text.strip() for item in soup.find_all('h2')],
        "paragraphs": [item.text.strip() for item in soup.find_all('p')],
        "links": [a["href"] for a in soup.find_all('a', href=True)]
    }
    return {"scraped_data": data}

