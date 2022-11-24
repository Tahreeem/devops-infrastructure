output "aws_instance_master_public_ip" {
  value = module.k8s_network.aws_instance_master_public_ip
}

output "aws_instance_worker_public_ip" {
  value = module.k8s_network.aws_instance_worker_public_ip
}