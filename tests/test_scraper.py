import unittest
from scraper.scraper import scrape_website

class TestScraper (unittest.TestCase):
    def test_scraper(self):
        result = scrape_website("https://example.com")
        self.assertIsInstance(result, dict)
        self.assertIn("scraped_data", result)

if __name__ == '__main__':
    unittest.main()