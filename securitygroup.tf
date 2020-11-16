
### Create security group for public subnet

# Allow internet to connect lb (http) and bastion host (ssh)
module "public-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name       = "public_allow_http_ssh"
  description = "Allows http and ssh access from other subnet"
  vpc_id      =  module.vpc.vpc_id

  ingress_with_cidr_blocks = [
# Commented to block front-end from internet
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow http"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow http"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   =  22
      to_port     =  22
      protocol    = "tcp"
      description = "Allow http"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule                     = "all-all"
      cidr_blocks              = "0.0.0.0/0"
    }
  ]
}

###Create security group for private subnet

# Allow loadbalancer from public security group to access vault and consul ports


module "vault-private-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name       = "private_allow_http_ssh"
  description = "Allows http and ssh access from public subnet only"
  vpc_id      =  module.vpc.vpc_id


  ingress_with_source_security_group_id = [
    {
      from_port   = 8200
      to_port     = 8200
      protocol    = "tcp"
      description = "Allow vault api"
      source_security_group_id =   module.public-sg.this_security_group_id
    },
    {
      from_port   = 8201
      to_port     = 8201
      protocol    = "tcp"
      description = "Allow vault cluster port"
      source_security_group_id =   module.vault-private-sg.this_security_group_id
    },
    {
      from_port   = 8300
      to_port     = 8300
      protocol    = "tcp"
      description = "Allow consul api"
      source_security_group_id =   module.public-sg.this_security_group_id
    },
    {
      from_port   = 8500
      to_port     = 8500
      protocol    = "tcp"
      description = "Allow consul ui"
      source_security_group_id =   module.public-sg.this_security_group_id
    },
    {
      from_port   = 8300
      to_port     = 8300
      protocol    = "tcp"
      description = "Allow consul raft"
      source_security_group_id =   module.vault-private-sg.this_security_group_id
    },
    {
      from_port   =  22
      to_port     =  22
      protocol    = "tcp"
      description = "Allow ssh"
      source_security_group_id =   module.public-sg.this_security_group_id
    }
  ]
  egress_with_cidr_blocks = [
    {
      rule                     = "all-all"
      cidr_blocks              = "0.0.0.0/0"
    }
  ]
}


