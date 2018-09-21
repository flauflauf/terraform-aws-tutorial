provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "my_instance" {
  ami = "ami-0773391ae604c49a4"    # Ubuntu 16.04 LTSLinux 2 AMI (region-specific)
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.my_security_group.name}"]

  tags {
    Name = "My Instance"
  }
}

resource "aws_security_group" "my_security_group" {
  name        = "My Security Group"

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Ping/ICMP access from anywhere"
  }
}

output "dns" {
  value = "${aws_instance.my_instance.public_dns}"
}
