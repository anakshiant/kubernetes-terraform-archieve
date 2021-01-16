variable "environment" {
  description = "The development environment (sandbox, development, staging, production)"
}

variable "image_tag" {
  description = "The tag for the Docker image (git SHA)"
}

variable "environment_variables" {
  description = "Map of all the environment variables used by the apps and monitors"
  type        = map
}



