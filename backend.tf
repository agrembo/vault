terraform {
  backend "s3" {
    bucket         = "tf-states-demo"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}
