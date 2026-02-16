variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  default     = "Strapi-Server-Task5"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 24.04 (us-east-1)"
  default     = "ami-04b70fa74e45c3917" 
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair to create"
  default     = "task5-key"
}

variable "docker_image" {
  description = "The Docker Hub image to pull"
  # REPLACE THIS WITH YOUR ACTUAL DOCKER HUB USERNAME!
  default     = "sagarpatade1900/strapi-app:slim"
}

variable "public_key" {
  description = "The public SSH key for the EC2 instance"
  type        = string
}