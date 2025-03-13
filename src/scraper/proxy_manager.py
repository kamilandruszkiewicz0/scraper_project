import requests
import random

def fetch_proxies():
    response = requests.get("https://api.proxyscrape.com/?request=getproxies")
    return response.text.split("\n")

PROXIES = fetch_proxies()
USER_AGENTS = ["Mozilla/5.0", "Chrome/91.0"]

def get_headers():
    return {"User-Agent": random.choice(USER_AGENTS)}

def get_proxy():
    if not PROXIES:
        return {}
    return {"http": random.choice(PROXIES)}
