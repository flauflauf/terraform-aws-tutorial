provider "aws" {
  region = "eu-west-1"
}

resource "aws_security_group" "my_security_group" {
  name        = "My Security Group"

  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   description = "HTTPS access from anywhere"
  # }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Ping/ICMP access from anywhere"
  }

  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   description = "outbound internet access"
  # }
}

resource "aws_instance" "my_instance" {
  ami                    = "ami-0bdb1d6c15a40392c"                             # Amazon Linux 2 AMI (region-specific)
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.my_security_group.id}"]

  tags {
    Name = "My instance"
  }
}
