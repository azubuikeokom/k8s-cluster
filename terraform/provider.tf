terraform {
  backend "s3" {
    bucket = "terraform-bucket0123"
    key    = "terraform.tfstate"
    dynamodb_table = "s3-table"
    region = "us-east-1"
  }


  required_providers{
    aws={
         source  = "hashicorp/aws"
         version = "> 3.0.0"
    }
  }
}
provider "aws"{
    region= "us-east-1"
    access_key = var.access_key
    secret_key = var.secret_key
}