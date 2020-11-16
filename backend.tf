terraform {
  backend "s3" {
    bucket         = "tf-states-demo"
    key            = "vault-dev-terraform.tfstate"
    region         = "us-east-1"
  }
}
