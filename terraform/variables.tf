variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "availability_zone" {
  type    = string
  default = "us-east-1a"
}

variable "aws_ami_master" {
  type = string
}

variable "aws_ami_worker" {
  type = string
}

variable "num_workers" {
  type    = number
  default = 1
}

variable "my_public_ip" {
  type = string
}
