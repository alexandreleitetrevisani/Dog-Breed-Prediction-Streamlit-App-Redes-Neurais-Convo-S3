terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # Configuração do backend remoto (Crie este bucket S3 e tabela DynamoDB manualmente antes)
  backend "s3" {
    bucket         = "breed-dog-bucket-terra"
    key            = "streamlit-dog-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
  }
}

provider "aws" {
  region = var.aws_region
}

