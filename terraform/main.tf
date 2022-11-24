terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-practice-tahreem"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

module "network" {
  source            = "./modules/network"
  availability_zone = var.availability_zone
  subnet_cidr       = var.subnet_cidr
  vpc_cidr          = var.vpc_cidr
  my_public_ip      = var.my_public_ip
}

module "k8s_network" {
  source                     = "./modules/k8s"
  vpc_id                     = module.network.vpc_id
  subnet_id                  = module.network.subnet_id
  base_aws_security_group_id = module.network.base_aws_security_group_id
  aws_ami_master             = var.aws_ami_master
  aws_ami_worker             = var.aws_ami_worker
  num_workers                = var.num_workers
  my_public_ip               = var.my_public_ip
}
