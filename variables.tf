# variables.tf
variable "aws_region" {
  description = "AWS region for the EC2 instance"
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing AWS Key Pair name"
  default     = "website_responsive"
}
