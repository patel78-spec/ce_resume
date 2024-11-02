terraform {
  backend "s3" {
    bucket = "test-backend-tfstate-dp"
    key    = "prod_web/terraform.tfstate"
  }
}