provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "my_instance" {
  ami = "ami-0773391ae604c49a4"    # Ubuntu 16.04 LTSLinux 2 AMI (region-specific)
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.my_security_group.name}"]
  user_data = "${file("userdata.sh")}"

  tags {
    Name = "My Instance"
  }
}

resource "aws_security_group" "my_security_group" {
  name = "My Security Group"

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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "outbound internet access"
  }
}

output "dns" {
  value = "${aws_instance.my_instance.public_dns}"
}
