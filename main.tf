provider "aws" {
  region = "eu-west-1"
}

resource "aws_security_group" "my_security_group" {
  name = "My Security Group"

  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   description = "HTTPS access from anywhere"
  # }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access from anywhere"
  }
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Ping/ICMP access from anywhere"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access from anywhere"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "outbound internet access"
  }
}

resource "aws_key_pair" "mine" {
  key_name   = "my-key"
  public_key = "${file("/Users/florianvonstosch/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "my_instance" {
  ami                    = "ami-0773391ae604c49a4"                        # Ubuntu 16.04 LTS
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.my_security_group.id}"]
  key_name               = "${aws_key_pair.mine.id}"
  user_data              = "${file("userdata.sh")}"

  tags {
    Name = "My instance"
  }
}
