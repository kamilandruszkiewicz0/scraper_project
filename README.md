# 🚀 Serverless Web Scraper  

A **highly scalable web scraper** using **AWS Lambda, Terraform, and Docker**, supporting both **static (Requests, BeautifulSoup)** and **dynamic (Selenium)** web scraping.  

## 🛠️ Tech Stack  
- **Python** (Requests, BeautifulSoup, Selenium)  
- **AWS Lambda** (Serverless execution)  
- **AWS DynamoDB** (NoSQL storage)  
- **AWS S3** (Storing scraped data)  
- **AWS API Gateway** (Triggering Lambda via HTTP API)  
- **AWS SQS** (Queue processing)  
- **Terraform** (Infrastructure as Code)  
- **Docker** (Containerized environment)  
- **GitHub Actions** (CI/CD automation)  

---

## 🔥 Features  
✅ **Static & Dynamic Web Scraping** – Uses Requests & Selenium  
✅ **Serverless Architecture** – Scalable, pay-per-use model  
✅ **Terraform-Managed Infrastructure** – Fully reproducible AWS setup  
✅ **Optimized IAM Roles** – Follows the least privilege principle  
✅ **Automated Deployment** – Can be integrated with GitHub Actions  

---

## 📚 Setup & Deployment  
### 1️⃣ **Deploy the Infrastructure**  
```bash
cd terraform
terraform init
terraform apply
```

### 2️⃣ **Deploy the Lambda Function**  
```bash
zip lambda_function.zip lambda_function.py
aws lambda update-function-code --function-name scraper_lambda --zip-file fileb://lambda_function.zip
```

### 3️⃣ **Test the API**  
```bash
curl -X POST "https://your-api-gateway-url/prod/scrape" \
     -H "Content-Type: application/json" \
     -d '{"url": "https://example.com", "mode": "dynamic"}'
```

---

## 📂 Project Structure  
```
.
├── Dockerfile
├── Makefile
├── README.md
├── lambda_function.py
├── requirements.txt
├── src
│   └── scraper
│       ├── proxy_manager.py
│       ├── retry_logic.py
│       ├── scraper.py
│       └── selenium_scraper.py
├── step_functions
│   └── step_function.json
├── terraform
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── tests
│   ├── test_lambda.py
│   └── test_scraper.py
└── venv/
    ├── bin/
    ├── include/
    ├── lib/
    ├── lib64 -> lib
    └── pyvenv.cfg
```

---

## 🚀 Future Enhancements  
✅ **Add CI/CD Pipeline** for automated deployments  
✅ **Improve Caching** for scraped data  
✅ **Integrate CloudWatch Monitoring** for Lambda logs  

---

## 💜 License  
This project is licensed under the **MIT License** – free to use and modify.  

---

## 💡 Contributing  
Feel free to **fork this repository** and submit a **pull request** if you’d like to improve this project.  
Got questions or feedback? Drop a comment! 🚀