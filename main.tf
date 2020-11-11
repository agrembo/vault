
#### Create Instance

module "instance" {
  source                      = "git::https://github.com/cloudposse/terraform-aws-ec2-instance.git?ref=master"
  ssh_key_pair                = var.ssh_key_pair
  instance_type               = var.instance_type
  vpc_id                      = var.vpc_id
  associate_public_ip_address	= false
  ami			      = "ami-03019f3086b56872e"
  security_groups             = [ "sg-0ed5813663af9284d" ]
  subnet                      = var.subnet
  name                        = "vault"
  namespace                   = "akwa"
  stage                       = "demo"
}
