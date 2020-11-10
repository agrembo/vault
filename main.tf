locals {
  userdata = <<-USERDATA
    #!/bin/bash
    cat <<"__EOF__" > /home/ec2-user/.ssh/config
    Host *
      StrictHostKeyChecking no
    __EOF__
    chmod 600 /home/ec2-user/.ssh/config
    chown ec2-user:ec2-user /home/ec2-user/.ssh/config
  USERDATA
}



#### Create Instance

module "instance" {
  source                      = "git::https://github.com/cloudposse/terraform-aws-ec2-instance.git?ref=master"
  ssh_key_pair                = var.ssh_key_pair
  instance_type               = var.instance_type
  vpc_id                      = var.vpc_id
  associate_public_ip_address	= false
  user_data_base64            = "${base64encode(local.userdata)}"
  security_groups             = [ "sg-0ed5813663af9284d" ]
  subnet                      = var.subnet
  name                        = "vault"
  namespace                   = "akwa"
  stage                       = "demo"
}
