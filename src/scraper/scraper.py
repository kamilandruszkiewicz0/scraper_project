import re
import requests
from bs4 import BeautifulSoup
from scraper.retry_logic import retry_request
from scraper.proxy_manager import get_headers, get_proxy
from urllib.parse import urlparse

def is_valid_url(url):
    try:
        result = urlparse(url)
        return all([result.scheme in ['http', 'https'], result.netloc])
    except ValueError:
        return False

def scrape_website(url):
    if not is_valid_url(url):  
        return {"statusCode": 400, "body": "Invalid URL format"}

    headers = get_headers()
    proxy = get_proxy()

    response = retry_request(lambda: requests.get(url, headers=headers, timeout=10, proxies=proxy))

    if not response or response.status_code != 200:
        return {"statusCode": 500, "body": "Failed to fetch data"}

    soup = BeautifulSoup(response.text, 'html.parser')
    data = {
        "titles": [item.text.strip() for item in soup.find_all('h2')],
        "paragraphs": [item.text.strip() for item in soup.find_all('p')],
        "links": [a["href"] for a in soup.find_all('a', href=True)]
    }
    return {"statusCode": 200, "scraped_data": data}
