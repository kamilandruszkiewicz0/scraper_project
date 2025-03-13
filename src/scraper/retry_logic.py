import time
import random
import logging

logging.basicConfig(level=logging.INFO)

def retry_request(func, retries=5):
    for i in range(retries):
        try:
            return func()
        except Exception as e:
            wait_time = 2 ** i + random.uniform(0,1)
            logging.warning(f"Retry {i+1}/{retries} failed: {e}. Retrying in {wait_time:.2f}s")
            time.sleep(wait_time)
    logging.error("All retries failed.")
    return None
