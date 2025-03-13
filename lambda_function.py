import json
import os
import logging
from scraper.scraper import scrape_website
from scraper.selenium_scraper import scrape_dynamic_website
from scraper.scraper import is_valid_url

logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"), format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

class LambdaScraper:
    def __init__(self, url: str, mode: str = "static"):
        self.url = url
        self.mode = mode
    
    def execute(self):
        try:
            if self.mode == "dynamic":
                result = scrape_dynamic_website(self.url)
                # Dla dynamic scraper nie było walidacji URL, więc ją dodajemy:
                if not is_valid_url(self.url):
                    logger.warning("Invalid URL format provided.")
                    return {"statusCode": 400, "body": json.dumps({"error": "Invalid URL format"})}
            else:
                result = scrape_website(self.url)

                # jeśli scrape_website zwrócił błąd, propagujemy go poprawnie
                if result.get("statusCode", 200) != 200:
                    logger.warning(f"Scraper returned error: {result.get('body')}")
                    return {
                        "statusCode": result["statusCode"],
                        "body": json.dumps({"error": result.get("body")})
                    }

            logger.info("Scraping ended successfully")
            return {"statusCode": 200, "body": json.dumps(result)}

        except Exception as e:
            logger.error(f"Scraping error: {str(e)}")
            return {"statusCode": 500, "body": json.dumps({"error": str(e)})}

def lambda_handler(event, context):
    url = event.get("url")
    mode = event.get("mode", "static")

    if not url:
        logger.warning("Missing URL in request")
        return { "statusCode": 400, "body": json.dumps({"error": "URL is required"})}
    
    lambda_scraper = LambdaScraper(url, mode)
    return lambda_scraper.execute()
