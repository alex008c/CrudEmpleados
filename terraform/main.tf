terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    docker = {
      source = "kreuzwerber/docker"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "docker" {}

variable "api_key_value" {
  description = "El valor secreto para la API KEY debe ser seguro."
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "La región AWS donde se desplegarán los recursos."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Un nombre base para identificar los recursos."
  type        = string
  default     = "crud-app"
}