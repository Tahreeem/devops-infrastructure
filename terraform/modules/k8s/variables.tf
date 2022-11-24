variable "aws_ami_master" {
  type = string
}

variable "aws_ami_worker" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "num_workers" {
  type    = number
  default = 1
}

variable "my_public_ip" {
  type = string
}

variable "base_aws_security_group_id" {
  type = string
}
