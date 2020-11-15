locals {
  userdata = <<-USERDATA
    #!/bin/bash
    echo "Deploy consul"
    wget https://releases.hashicorp.com/consul/1.8.5/consul_1.8.5_linux_amd64.zip -O /tmp/consul.zip
    unzip /tmp/consul.zip -d /usr/bin/

    mkdir -p /usr/local/bin/consul /var/consul/data
    IPADDR=`ifconfig eth0 | grep "inet " | awk -F'[: ]+' '{ print $3 }'`
    NODE_NAME=`hostname`
    cat << EOF > /usr/local/etc/consul/consul.json
    {
      "server": true,
      "node_name": "$NODE_NAME",
      "datacenter": "dc1",
      "data_dir": "/var/consul/data",
      "bind_addr": "0.0.0.0",
      "client_addr": "0.0.0.0",
      "advertise_addr": "$IPADDR",
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
    ExecStartPre=/bin/chown -R consul:consul /var/run/consul
    ExecStart=/usr/local/bin/consul agent \
        -config-file=/usr/local/etc/consul/consul_s1.json \
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
    
  USERDATA
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
  min_size                    = 1
  max_size                    = 6
  wait_for_capacity_timeout   = "5m"
  associate_public_ip_address = false
  user_data_base64            = "${base64encode(local.userdata)}"
  key_name                    = aws_key_pair.vault-private.key_name
  target_group_arns           = [ aws_lb_target_group.vault.arn ]

  tags = {

      namespace   = var.namespace
      stage       = var.stage
      name        = "vault"

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