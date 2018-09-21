provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "my_instance" {
  ami = "ami-0773391ae604c49a4"    # Ubuntu 16.04 LTSLinux 2 AMI (region-specific)
  instance_type = "t2.micro"

  tags {
    Name = "My Instance"
  }
}
