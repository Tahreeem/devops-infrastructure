// TODO: pass aws_ami_master
data "aws_ami" "master" {
  most_recent = true

  owners = ["self"]

  filter {
    name   = "name"
    values = [var.aws_ami_master]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
// TODO: pass aws_ami_worker
data "aws_ami" "worker" {
  most_recent = true

  owners = ["self"]

  filter {
    name   = "name"
    values = [var.aws_ami_worker]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
data "aws_subnet" "k8s" {
  id = var.subnet_id
}





// ec2s
//TODO: pass subnet_id
resource "aws_instance" "master_ec2" {
  ami                         = data.aws_ami.master.id
  instance_type               = "t3.medium"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.master_allow_ssh.id, var.base_aws_security_group_id]
  key_name                    = "instance_rsa_june"
  user_data                   = templatefile("${path.module}/scripts/master-user-data.tftpl", {}) // user_data output is always saved to /var/log/cloud-init-output.log
  iam_instance_profile        = aws_iam_instance_profile.devops_test_profile.name

  tags = {
    Name = "Master Subnet EC2"
  }
}
//TODO: pass num_workers, subnet_id
resource "aws_instance" "worker_ec2" {
  count = var.num_workers

  ami                         = data.aws_ami.worker.id
  instance_type               = "t3.medium"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.worker_allow_ssh.id, var.base_aws_security_group_id]
  key_name                    = "instance_rsa_june"
  depends_on = [
    aws_instance.master_ec2
  ]
  user_data            = templatefile("${path.module}/scripts/worker-user-data.tftpl", { master_ip = aws_instance.master_ec2.private_ip })
  iam_instance_profile = aws_iam_instance_profile.devops_test_profile.name

  tags = {
    Name = "Worker Subnet EC2 ${count.index + 1}"
  }
}


// security groups
// TODO: supply vpc_id
resource "aws_security_group" "master_allow_ssh" {
  name        = "master_allow_ssh"
  description = "Allow SSH Master"
  vpc_id      = var.vpc_id

  tags = {
    Name = "Master Security Group"
  }
}
// TODO: supply vpc_id
resource "aws_security_group" "worker_allow_ssh" {
  name        = "worker_allow_ssh"
  description = "Allow SSH Worker"
  vpc_id      = var.vpc_id

  tags = {
    Name = "Worker Security Group"
  }
}

# instances are stateful meaning you only need to specify ingress rule and egress is implied
# NACLs i.e. the rules on VPCs on the other hand are statless meaning they require both ingress and egress rules

# in this case it's only port 6443 that needs to be able to communicate with "All" which is why it requires an ingress rule
# but the other ports only need internal to VPC communication so they don't even need ingress rules
resource "aws_security_group_rule" "master_ingress_6443" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = [var.my_public_ip, data.aws_subnet.k8s.cidr_block]
  security_group_id = aws_security_group.master_allow_ssh.id
}
resource "aws_security_group_rule" "master_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.master_allow_ssh.id
}

resource "aws_security_group_rule" "worker_ingress_30000" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  cidr_blocks       = [var.my_public_ip, data.aws_subnet.k8s.cidr_block]
  security_group_id = aws_security_group.worker_allow_ssh.id
}
resource "aws_security_group_rule" "worker_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker_allow_ssh.id
}

# ----------------------------------------

# - Create the rest of the security group rules for the master - https://kubernetes.io/docs/reference/ports-and-protocols/
# - Create the worker resources
# - Launch EC2 instances
# - figure out how to pass info for kubectl commands to join cluster


resource "aws_iam_role" "devops_test_role" {
  name = "devops_test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "devops_iam_policy_document" {
  statement {
    sid = "1"

    actions = [
      "ssm:*"
    ]

    resources = [
      "arn:aws:ssm:us-east-1:*:parameter/*",
    ]
  }
}

resource "aws_iam_policy" "devops_test_policy" {
  name   = "devops_test_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.devops_iam_policy_document.json
}

resource "aws_iam_role_policy_attachment" "devops_test_attach" {
  role       = aws_iam_role.devops_test_role.name
  policy_arn = aws_iam_policy.devops_test_policy.arn
}

resource "aws_iam_instance_profile" "devops_test_profile" {
  name = "devops_test_profile"
  role = aws_iam_role.devops_test_role.name
}
