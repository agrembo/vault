# Vault HA

Terraform script to deploy vault HA cluster with consul as backend on AWS EC2 environment.


![vault cluster](https://github.com/agrembo/vault/blob/main/Vault-cluster.jpeg)


## Installation

Download and configure terraform with appropriate version 


```bash
wget https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip  -O /tmp/terraform.zip
unzip /tmp/terraform.zip -d /usr/local/bin/

mkdir workspace
git clone  https://github.com/agrembo/vault.git
git checkout vault-cluster
```

## Usage
Make sure you have right permission to create resources on EC2. 


```bash
cd vault-cluster

# Load TF modules
terraform init

# Verify the changes
terraform plan

# Deploy vault cluster with consul backed
terraform apply

# Destroy everything
terraform destroy
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)

