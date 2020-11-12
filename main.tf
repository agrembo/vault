locals {
  userdata = <<-USERDATA
    #!/bin/bash
    echo "Deployed via terraform" > /tmp/data
    echo "Deploying vault"
    wget https://releases.hashicorp.com/vault/1.6.0/vault_1.6.0_linux_amd64.zip -O /tmp/vault.zip
    unzip /tmp/vault.zip -d /usr/bin/
    rm -rf /tmp/vault.zip
    screen -d -m /usr/bin/vault server -dev -dev-listen-address=0.0.0.0:8200 -dev-root-token-id=bingo
    
    ## Testing vault policies
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
    

    # Test Policy
    vault login -method=userpass username=akwa password=akwa
    
    # Write some keys
    vault kv put secret/hello foo=world

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
