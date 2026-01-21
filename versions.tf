terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket                 = "tf-state-xavi-2024-zaragoza-v1" # El nombre del bucket debe ser unico a nivel global
    key                    = "global/s3/terraform.tfstate"
    region                 = "eu-south-2"      # La region donde esta el bucket
    dynamodb_table         = "terraform-locks" # Tabla para locking
    encrypt                = true              # Encriptacion del state en el bucket
    skip_region_validation = true
  }
  provider "aws" {
    region = var.region_aws # usamos la region de ES en zaragoza
  }
  # Opcional: Etiquetas por defecto para todos los recursos
  default_tags {
    tags = {
      Owner     = "Xavi"
      ManagedBy = "Terraform"
    }
  }
}
