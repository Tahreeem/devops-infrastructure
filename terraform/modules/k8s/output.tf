output "aws_instance_master_public_ip" {
  value = aws_instance.master_ec2.public_ip
}

output "aws_instance_worker_public_ip" {
  value = aws_instance.worker_ec2.*.public_ip
}