install:
	pip install -r requirements.txt

test:
	pytest tests/

lint:
	flake8 .

deploy:
	terraform -chdir=terraform apply -auto-approve

run:
	unicorn main:app --host 0.0.0.0 --port 8000