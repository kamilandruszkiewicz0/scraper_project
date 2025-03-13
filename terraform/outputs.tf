output "lambda_arn" {
  description = "ARN for the scraper Lambda function"
  value       = aws_lambda_function.scraper_lambda.arn
}

output "api_url" {
  description = "URL to trigger the scraper via API Gateway"
  value       = aws_api_gateway_deployment.scraper_deployment.invoke_url
}

output "api_endpoint" {
  description = "The API Gateway endpoint for the scraper"
  value       = aws_api_gateway_deployment.scraper_deployment.invoke_url
}

output "s3_bucket_name" {
  description = "S3 bucket name where data is stored"
  value       = aws_s3_bucket.scraper_data.id
}
