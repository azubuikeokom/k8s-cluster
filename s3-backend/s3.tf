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
resource "aws_s3_bucket" "s3" {
  bucket = "terraform-bucket0123"
  object_lock_enabled = true

}
resource "aws_s3_bucket_object_lock_configuration" "lock" {
  bucket = aws_s3_bucket.s3.bucket

  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = 5
    }
  }
}