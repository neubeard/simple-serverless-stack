terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "./../terraform.tfstate"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}
