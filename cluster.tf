data "template_file" "user_data" {
  template = "${file("userdata.tpl")}"

  vars = {
    elb_dns_name = "${aws_elb.this.dns_name}"
  }
}


module "vault_autoscale_group" {
  source = "git::https://github.com/cloudposse/terraform-aws-ec2-autoscale-group.git?ref=master"

  namespace   = var.namespace
  stage       = var.stage
  name        = "vault"

  image_id                    = var.ami_id
  instance_type               = "t2.micro"
  security_group_ids          = [ module.vault-private-sg.this_security_group_id ]
  subnet_ids                  = values(module.private_subnets.az_subnet_ids)
  health_check_type           = "EC2"
  min_size                    = var.instance_count
  max_size                    = 6
  wait_for_capacity_timeout   = "5m"
  associate_public_ip_address = false
  #user_data_base64            = "${base64ncode(local.userdata)}"
  user_data_base64             = "${base64encode(data.template_file.user_data.rendered)}"
  key_name                    = aws_key_pair.vault-private.key_name
 # target_group_arns           = [ aws_lb_target_group.vault.arn , aws_lb_target_group.consul.arn ]
  load_balancers              = [ aws_elb.this.name ]
  iam_instance_profile_name   = "ec2allowdescribe"
  scale_up_cooldown_seconds   = 120
  scale_down_cooldown_seconds = 20
  

  tags = {

      namespace   = var.namespace
      stage       = var.stage
      name        = "vault"
      app         = "consul"

  }

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = "true"
  cpu_utilization_high_threshold_percent = "70"
  cpu_utilization_low_threshold_percent  = "20"
}



# Create aws key from public key
resource "aws_key_pair" "vault-private" {
  key_name   = "vault-private-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNSwn/iqZfKM5alMdiEvv2pQaYaWf7a0AjYLqISd6LglGAjy12r70n1gBXOAnJjn0QjoaMworyWqA7TKVFCpMdBqG1BIGu6n9btJQcJmObO+MzjqJmZtKV8rea5259ib/XSf4AT6wcd6tnj7SNwDEGPTqY3ZuUrh0qgPrV8LavTP5efXhfUiCuD/0iwXv45IOdEW8pX/qLeGW1CWJ7RvLBJOfkUZhayo4lwErb0gR5tCq8o3UqFMfqn+VOdY9ZMDba6ivE82Lu++xAFdro58NDyrYNl7Eb2SUxM0kKXzpJrUdZI/5kho1cbUKzRVXBOxrJ3NyhN42Fw+XDFzwo+FDzF9CeG6puyP+sDhxNbVOq3Y4IYRtvN4cFt4ZPCje5krT5kCIFR7x5MNSlaUHBIf9JPxPHR9Y7RXokn6ESb9vaAVX87Px4PRKk2l2tlGgrDxt24ichv3pfDOaswFEFAAFIg+s47yr9wbnpIeJWbv26N6ZulgDIMUFvUFGVdJmTBXU= root@DESKTOP-P1FOB5D"
}
