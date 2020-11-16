variable "namespace" {
    type = string
    default = "myorg"
}


variable "stage" {
    type = string
    default = "demo"
}

variable "region" {
    type = string
    default = "us-east-1"

}

variable "cidr_block" {
    type = string
    default = "192.168.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zone IDs"
  default     = ["us-east-1a", "us-east-1b"]
}


variable "ami_id" {
    type     =  string
    description = "Default AMI is amazon linux"
    default     = "ami-0947d2ba12ee1ff75"
}

variable "elb_name" {
    type = string
    description = "(optional) describe your variable"
    default = "vault"
}


variable "instance_count" {
    type = string
    default = 1
}