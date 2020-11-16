#!/bin/bash
echo "Deploy consul"
wget https://releases.hashicorp.com/consul/1.8.5/consul_1.8.5_linux_amd64.zip -O /tmp/consul.zip
unzip /tmp/consul.zip -d /usr/bin/
mkdir -p /usr/local/etc/consul /var/consul/data
IPADDR=`ifconfig eth0 | grep "inet " | awk -F'[: ]+' '{ print $3 }'`
NODE_NAME=`hostname -s`
cat << EOF > /usr/local/etc/consul/consul.json
{
  "server": true,
  "node_name": "$NODE_NAME",
  "datacenter": "dc1",
  "data_dir": "/var/consul/data",
  "bind_addr": "0.0.0.0",
  "client_addr": "0.0.0.0",
  "advertise_addr": "$IPADDR",
  "retry_join": ["provider=aws tag_key=app tag_value=consul"],
  "bootstrap_expect": 3,
  "ui": true,
  "log_level": "DEBUG",
  "enable_syslog": true,
  "acl_enforce_version_8": false
}
EOF
# Create systemd for consul
cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description=Consul server agent
Requires=network-online.target
After=network-online.target
[Service]
PIDFile=/var/run/consul/consul.pid
PermissionsStartOnly=true
ExecStartPre=-/bin/mkdir -p /var/run/consul
ExecStart=/usr/bin/consul agent -server\
    -config-file=/usr/local/etc/consul/consul.json \
    -pid-file=/var/run/consul/consul.pid
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=42s
[Install]
WantedBy=multi-user.target
EOF
systemd daemon-reload
systemctl start consul
systemctl enable consul



## Deploying vault

wget https://releases.hashicorp.com/vault/1.6.0/vault_1.6.0_linux_amd64.zip -O /tmp/vault.zip
unzip /tmp/vault.zip -d /usr/bin/
mkdir -p /etc/vault/

cat << EOF > /etc/vault/vault_server.hcl
ui = true
listener "tcp" {
  address          = "0.0.0.0:8200"
  cluster_address  = "$IPADDR:8201"
  tls_disable      = "true"
}

storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault/"
}

api_addr =  "http://${elb_dns_name}:8200"
cluster_addr = "http://${elb_dns_name}:8201"
EOF


# Create systemctl file

cat << EOF > /etc/systemd/system/vault.service
[Unit]
Description=Vault secret management tool
Requires=network-online.target
After=network-online.target

[Service]
PIDFile=/var/run/vault.pid
ExecStart=/usr/bin/vault server -config=/etc/vault/vault_server.hcl -log-level=debug
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=42s
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF

systemd daemon-reload

systemctl start vault
systemctl enable vault

sleep 20s

# Initialize vault
export VAULT_ADDR="http://127.0.0.1:8200"
export CONSUL_ADDR="http://127.0.0.1:8500"

echo "Running this script will initialize & unseal Vault, then put your unseal keys and root token into Consul KV."

cget() { curl -sf "$CONSUL_ADDR/v1/kv/service/vault/$1?raw"; }

if [ ! $(cget root-token) ]; then
  echo "Initialize Vault"
  vault operator init | tee /tmp/vault.init
  COUNTER=1 ; for i in `cat /tmp/vault.init | grep '^Unseal' | awk '{print $4}'` ; do curl -fX PUT $CONSUL_ADDR/v1/kv/service/vault/unseal-key-$COUNTER -d $i ; sleep 2s ;  COUNTER=$((COUNTER + 1)) ; done
  export ROOT_TOKEN=`cat /tmp/vault.init | grep '^Initial' | awk '{print \$4}'`
  curl -fX PUT $CONSUL_ADDR/v1/kv/service/vault/root-token -d $ROOT_TOKEN
fi


echo "Unsealing Vault"
vault operator unseal $(cget unseal-key-1)
vault operator unseal $(cget unseal-key-2)
vault operator unseal $(cget unseal-key-3)
