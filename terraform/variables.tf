variable "environment" {
  description = "The development environment (sandbox, development, staging, production)"
}

variable "image_tag" {
  description = "The tag for the Docker image (git SHA)"
}

variable "aws_access_key_id" {
  description = "AWS Access Key for AWS account to provision resources on."
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key for AWS account to provision resources on."
}

variable "aws_region" {
  description = "The AWS region resources are created in."
}

variable "environment_variables" {
  description = "Map of all the environment variables used by the apps"
  type        = map(any)
}


