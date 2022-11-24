output "vpc_id" {
  value       = aws_vpc.vpc_cidr.id
  description = "VPC ID"
}

output "subnet_id" {
  value       = aws_subnet.subnet_cidr.id
  description = "VPC SUBNET ID"
}

output "base_aws_security_group_id" {
  value       = aws_security_group.devops_infra_allow_ssh.id
  description = "BASE SECURITY GROUP ID"
}
