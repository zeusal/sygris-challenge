terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.69.0"
      configuration_aliases = [ aws.management ]
    }
  }
}

resource "aws_key_pair" "jumphost" {
  provider   = aws.management
  key_name   = "deployer-key"
  public_key = "${var.pub_key}"
}

resource "aws_instance" "jumphost" {
  provider                    = aws.management
  ami                         = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${var.public_subnet_id}"
  associate_public_ip_address = "true"
  vpc_security_group_ids      = ["${var.default_sg}", "${var.internet_sg}", "${var.ssh_sg}"]
  key_name                    = aws_key_pair.jumphost.id

  user_data = <<-EOF
              #!/bin/bash
              mkdir -p /home/${var.ssh_user}/.ssh/
              echo "${var.priv_key}" |base64 -d >> /home/${var.ssh_user}/.ssh/id_rsa
              echo "${var.pub_key}" >> /home/${var.ssh_user}/.ssh/id_rsa.pub
              echo "${var.pub_key}" >> /home/${var.ssh_user}/.ssh/authorized_keys
              chown ${var.ssh_user} /home/${var.ssh_user}/.ssh/id_rsa*
              chgrp ${var.ssh_user} /home/${var.ssh_user}/.ssh/id_rsa*
              chmod 600 /home/${var.ssh_user}/.ssh/id_rsa
              chmod 644 /home/${var.ssh_user}/.ssh/authorized_keys /home/${var.ssh_user}/.ssh/id_rsa.pub
              yum update -y
              yum install ansible -y 
              EOF

  tags = {
    Name        = "${var.project}-jumphost"
  }
}