import json
import pytest
import sys
import os 
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from lambda_function import lambda_handler

def test_lambda_static():
    event = {"url": "https://example.com", "mode": "static"}
    response = lambda_handler(event, None)
    
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert "scraped_data" in body

def test_lambda_dynamic():
    event = {"url": "https://example.com", "mode": "dynamic"}
    response = lambda_handler(event, None)
    
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert "scraped_data" in body

def test_lambda_no_url():
    event = {"mode": "static"}
    response = lambda_handler(event, None)

    assert response["statusCode"] == 400  
    body = json.loads(response["body"])
    assert "error" in body

def test_lambda_invalid_url():  
    event = {"url": "invalid-url", "mode": "static"}
    response = lambda_handler(event, None)

    assert response["statusCode"] == 400
    body = json.loads(response["body"])
    assert body["error"] == "Invalid URL format"
