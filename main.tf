locals {
  userdata = <<-USERDATA
    #!/bin/bash
    cat <<"__EOF__" > /home/ec2-user/.ssh/config
    Host *
      StrictHostKeyChecking no
    __EOF__
    chmod 600 /home/ec2-user/.ssh/config
    chown ec2-user:ec2-user /home/ec2-user/.ssh/config
    
# Install consul
mkdir /tmp/

cd /tmp/

wget https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_linux_amd64.zip


unzip consul_1.6.1_linux_amd64.zip

mv consul /usr/bin

mkdir /tmp/consul /etc/consul.d/

ipaddress=`ifconfig eth0 | grep "inet " | awk -F'[: ]+' '{ print $3 }'`
cat <<EOF > /etc/systemd/system/consul.service
[Unit]
Description=Consul
Documentation=https://www.consul.io/
[Service]
ExecStart=/usr/bin/consul agent -server -ui -bind=$ipaddress -data-dir=/tmp/consul/ -bootstrap-expect=1 -node=vault -config-dir=/etc/consul.d/
ExecReload=/bin/kill –HUP $MAINPID
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF



cat <<EOF > /etc/consul.d/ui.json
{
        "addresses": {
                        "http": "0.0.0.0"
        }
}
EOF




systemctl daemon-reload

systemctl start consul

systemcl enable consul




echo "Deploying Vault"


wget https://releases.hashicorp.com/vault/1.2.3/vault_1.2.3_linux_amd64.zip

unzip vault_1.2.3_linux_amd64.zip
mv vault /usr/bin
mkdir /etc/vault
cat <<EOF > /etc/vault/config.hcl
storage "consul" {
address = "127.0.0.1:8500"
path = "vault/"
}
listener "tcp" {
address = "0.0.0.0:8200"
tls_disable = 1
}
ui = true
EOF

cat <<EOF > /etc/systemd/system/vault.service
[Unit]
Description=Vault
Documentation=https://www.consul.io/
[Service]
ExecStart=/usr/bin/vault server -config=/etc/vault/config.hcl
ExecReload=/bin/kill –HUP $MAINPID
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload

systemctl start vault

systemctl enable vault
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
