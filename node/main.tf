terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.vcluster.requirements["region"]
}

############################
# Look up the provided subnet
############################
data "aws_subnet" "target" {
  id = var.vcluster.nodeEnvironment.outputs["private_subnet_id"]
}

############################
# Security Group (egress-only by default)
############################
resource "aws_security_group" "instance_sg" {
  name   = "${var.vcluster.name}-sg"
  vpc_id = data.aws_subnet.target.vpc_id

  # Example inbound rule (SSH); adjust as needed
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.vcluster.name}-sg" }
}

############################
# EC2 instance
############################
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.vcluster.requirements["instance-type"]
  subnet_id                   = data.aws_subnet.target.id
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  user_data                   = var.vcluster.userData
  user_data_replace_on_change = true

  # --- Root disk sizing ---
  root_block_device {
    volume_size           = 60
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.vcluster.name}-ec2"
  }
}
