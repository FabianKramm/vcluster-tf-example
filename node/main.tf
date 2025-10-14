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
  region = var.vcluster.properties["region"]
}

############################
# Ubuntu AMI
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

############################
# EC2 instance
############################
resource "aws_instance" "this" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.vcluster.properties["instance-type"]
  subnet_id                   = var.vcluster.nodeEnvironment.outputs.infrastructure["private_subnet_id"]
  vpc_security_group_ids      = [var.vcluster.nodeEnvironment.outputs.infrastructure["security_group_id"]]
  user_data                   = var.vcluster.userData
  user_data_replace_on_change = true

  # --- Root disk sizing ---
  root_block_device {
    volume_size           = 100
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.vcluster.name}-ec2"
  }
}
