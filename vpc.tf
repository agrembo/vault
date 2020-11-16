# Creates VPC

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=master"
  namespace  = var.namespace
  name       = "vpc"
  stage      = var.stage
  cidr_block = var.cidr_block
}

locals {
  public_cidr_block  = cidrsubnet(module.vpc.vpc_cidr_block, 7, 0)
  private_cidr_block = cidrsubnet(module.vpc.vpc_cidr_block, 7, 10)
}

# Creates public and private subnet

module "public_subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=master"
  namespace           = var.namespace
  stage               = var.stage
  name                = "public"
  availability_zones  = var.availability_zones
  vpc_id              = module.vpc.vpc_id
  cidr_block          = local.public_cidr_block
  type                = "public"
  igw_id              = module.vpc.igw_id
  max_subnets         = "2"
  nat_gateway_enabled = "true"
}

module "private_subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=master"
  namespace           = var.namespace
  stage               = var.stage
  name                = "private"
  availability_zones  = var.availability_zones
  vpc_id              = module.vpc.vpc_id
  cidr_block          = local.private_cidr_block
  type                = "private"
  az_ngw_ids          = module.public_subnets.az_ngw_ids
  max_subnets         = "2"
}


