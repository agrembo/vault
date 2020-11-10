variable "vpc_id" {
  type = string
  default = "vpc-07d4508b74348dacb"

}

variable "ssh_key_pair" {
  type = string
  default = "vault-private"
}

variable "instance_type" {
  type = string
  default = "t2.medium"
}

variable "subnet" {
  type = string
  default = "subnet-08e3041363e87a0f4"
}

variable "public_sg_id" {
  type = string
  default = "sg-0ed5813663af9284d"
}
