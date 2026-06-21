terraform {
  backend "s3" {
    bucket         = "maia-terraform-state"
    key            = "cloud-landing-zone/sandbox/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "maia-terraform-locks"
  }
}