terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}

provider "aws" {
  /*region = var.region
  access_key = var.access_key
  secret_key = var.secret_key*/

}