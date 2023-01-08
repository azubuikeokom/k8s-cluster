terraform {
  required_providers{
    aws={
         source  = "hashicorp/aws"
         #version = "> 3.0.0"
    }
  }
}
provider "aws"{
    region= "us-east-1"
}
resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "s3-table"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "dynamodb-s3-table"
    Environment = "production"
  }
}