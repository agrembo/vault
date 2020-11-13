locals {
  userdata = <<-USERDATA
    #!/bin/bash
    echo "Deployed via terraform" > /tmp/data
    echo "Deploying vault"
    wget https://releases.hashicorp.com/vault/1.6.0/vault_1.6.0_linux_amd64.zip -O /tmp/vault.zip
    unzip /tmp/vault.zip -d /usr/bin/
    rm -rf /tmp/vault.zip
    screen -d -m /usr/bin/vault server -dev -dev-listen-address=0.0.0.0:8200 -dev-root-token-id=bingo
    
    ## Exporting vault address
    export VAULT_ADDR=http://127.0.0.1:8200
    vault login bingo
    # Enable userpass auth
    vault auth enable userpass
    
    # Create vault policy
    cat << POLICY > /tmp/policy
    path "secret/*" {
    capabilities = ["create", "read", "list", "update"]
    }
    POLICY

    vault policy write dev /tmp/policy
    # Create user and attach dev policy
    vault kv put auth/userpass/users/akwa policies=dev password=akwa
    

    # Logging into the vault with username/password
    vault login -method=userpass username=akwa password=akwa
    
    # Testing by Writting some keys
    vault kv put secret/hello foo=world

  USERDATA
}


# Create security group to allow vault api and ssh to jenkins sg

module "vault-private-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name       = "vault-allow-jenkins"
  description = "Allows 8200 and 22 to jenkins sg"
  vpc_id      =  var.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port		      = 8200
      to_port		      = 8200
      protocol		      = 6
      description	      = "vault api"
      source_security_group_id = var.public_sg_id 
    },
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = 6
      description              = "SSH"
      source_security_group_id = var.public_sg_id 
    },
  ]

}




module "vault_dev" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "vault-dev"
  instance_count         = 1

  ami                    = "ami-0947d2ba12ee1ff75"
  instance_type          = var.instance_type
  associate_public_ip_address	= "false"
  key_name               = var.ssh_key_pair
  monitoring             = true
  vpc_security_group_ids = [ module.vault-private-sg.this_security_group_id ]
  subnet_id              = var.subnet
  user_data_base64	 = "${base64encode(local.userdata)}"
  

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
