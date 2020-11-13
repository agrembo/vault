variable "vpc_id" {
  type = string
  default = "vpc-07d4508b74348dacb"

}

variable "ssh_key_pair" {
  type = string
  default = "demo-public"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "subnet" {
  type = string
  default = "subnet-08e3041363e87a0f4"
}

variable "public_sg_id" {
  type = string
  default = "sg-0ed5813663af9284d"
}


variable "source_security_group_id" {
  type = string
  default = "sg-062fe007ef208f3cb"
}
  
