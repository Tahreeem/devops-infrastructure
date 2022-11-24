packer {
  required_version = ">= 1.7.0"
}

source "amazon-ebs" "source_name" {
  ami_name                    = "worker-ami-{{timestamp}}"
  instance_type               = "t3.small"
  vpc_id                      = "vpc-00b2cb19b9c843963"
  associate_public_ip_address = true
  subnet_id                   = "subnet-07f98cb07b6449b60"
  ssh_username                = "ubuntu"
  ssh_interface               = "public_ip"
  // region                      = "us-east-1"

  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "*ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      // region                      = "us-east-1" // already in .aws/config
    }
    owners      = ["amazon"]
    most_recent = true
  }
}

build {
  # use the `name` field to name a build in the logs.
  # For example this present config will display
  # "buildname.amazon-ebs.example-1" and "buildname.amazon-ebs.example-2"
  name = "workerPackerLogs"

  sources = [
    # use the optional plural `sources` list to simply use a `source`
    # without changing any field.
    "source.amazon-ebs.source_name",
  ]

  provisioner "ansible" {
      playbook_file = "../ansible/worker.yml"
      extra_arguments = [ "-vvvv" ]
  }

  //   post-processor "shell-local" {
  //     inline = ["echo Hello World from ${source.type}.${source.name}"]
  //   }
}