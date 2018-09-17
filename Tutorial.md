Terraform grob erklären
=======================

- Orchestrierung von Infrastruktur
- IaC und deklarativ
- Funktioniert für diverse Cloud-Provider
- Idempotent: Terraform vergleicht Soll und Ist und berechnet Plan zum Angleichen


Terraform mit AWS verbinden
===========================

- AWS Account / IAM User erstellen
- AWS Access Key erstellen
- Access Key lokal bereitstellen:
````
aws configure
````
- aws als Provider in main.tf-Datei festlegen
````
provider "aws" {
  region = "eu-west-1"
}
````


EC2-Instanz starten
===================

main.tf-Datei um folgendes ergänzen:
````
resource "aws_instance" "my_instance" {
  ami           = "ami-0bdb1d6c15a40392c" # Amazon Linux 2 AMI (region-specific)
  instance_type = "t2.micro"

  tags {
    Name = "My Instance"
  }
}
````

````
terraform init
terraform apply
````


Über Security Group erreichbar machen
=====================================

main.tf-Datei um folgendes ergänzen:
````
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

resource "aws_instance" "my_instance" {
  ...
  vpc_security_group_ids = ["${aws_security_group.my_security_group.id}"]
}
````

Dann

    terraform apply


Mit "terraform show" (oder Output) die Public IP oder Public DNS herausfinden und

    ping x


Aufräumen
=========

Damit keine Kosten entstehen:

    terraform destroy