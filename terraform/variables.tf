variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "Bucket for storing scraped data"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table for storing results"
  default     = "ScraperResults"
}

variable "sqs_queue_name" {
  description = "Queue for handling scraping tasks"
  default     = "ScraperQueue"
}
