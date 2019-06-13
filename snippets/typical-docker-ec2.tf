# provider, variables, ...

data "aws_security_group" "gitlab-runner-security-group" {
  name = "team-x-gitlab-runner"
}

resource "aws_security_group" "security-group" {
  name = "${var.name}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.company_network_ip}"]
    description = "allow inbound SSH from our company and team-x gitlab-runner"

    security_groups = ["${data.aws_security_group.gitlab-runner-security-group.id}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all inbound HTTPS traffic"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all inbound HTTP traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all outbound traffic"
  }
}

data "aws_ami" "amazon_linux_2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name = "name"
    values = ["${var.amazon_linux_2_ami_name}"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "instance" {
  ami             = "${data.aws_ami.amazon_linux_2.id}"
  instance_type   = "t2.small"
  key_name        = "${var.ssh_key_name}"
  security_groups = ["${aws_security_group.security-group.name}"]

  tags {
    Name = "${var.name}"
  }

  root_block_device {
    volume_size = 20
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${var.ssh_private_key_path}")}"
    }

    inline = [
      # install docker
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo usermod -a -G docker ec2-user",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",

      # install docker-compose
      "sudo sh -c 'curl -L https://github.com/docker/compose/releases/download/${var.docker_compose_version}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose'",
      "sudo chmod +x /usr/local/bin/docker-compose",
    ]
  }
}
