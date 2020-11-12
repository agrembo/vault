locals {
  userdata = <<-USERDATA
    #!/bin/bash
    echo "Deployed via terraform" > /tmp/data
  USERDATA
}









module "vault_dev" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "vault-dev"
  instance_count         = 1

  ami                    = "ami-0947d2ba12ee1ff75"
  instance_type          = "t2.micro"
  associate_public_ip_address	= "false"
  key_name               = "demo-public"
  monitoring             = true
  vpc_security_group_ids = ["sg-062fe007ef208f3cb"]
  subnet_id              = "subnet-08e3041363e87a0f4"
  user_data_base64	 = "${base64encode(local.userdata)}"
  

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
