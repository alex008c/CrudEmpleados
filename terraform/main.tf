terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "docker" {}

data "aws_caller_identity" "current" {}

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

variable "environment" {
  description = "Ambiente de despliegue."
  type        = string
  default     = "dev"
}

variable "external_db_url" {
  description = "URL de conexión a la base de datos externa (ej: Supabase PostgreSQL)."
  type        = string
  sensitive   = true
}