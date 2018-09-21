# Terraform AWS Tutorial

In diesem Tutorial wird gezeigt, wie man Terraform einsetzen kann, um Infrastruktur bei AWS (oder einem anderen Cloud-Anbieter) zu beschreiben und erzeugen. Terraform ist ein Tool zur Infrastrukturautomatisierung, das wegen folgender Eigenschaften beliebt ist:

- IaC und deklarativ
- Funktioniert für diverse Cloud-Provider
- Idempotent: Terraform vergleicht Soll und Ist und berechnet Plan zum Angleichen


Vorbedingungen

- Terraform installieren
- AWS CLI installieren (optional)
- AWS Account / IAM User
- Erstellter AWS Access Key


## Terraform mit AWS verbinden

- Access Key lokal bereitstellen (mit AWS CLI, ansonsten auch händisch in `~/.aws/credentials`):
````
aws configure
````
- AWS als Provider in `main.tf`-Datei festlegen
````
provider "aws" {
  region = "eu-west-1"
}
````

Anschließend können wir Terraform initialisieren, wodurch automatisch das AWS Plugin heruntergeladen wird:

    terraform init


## EC2-Instanz starten

`main.tf`-Datei um folgendes ergänzen:
````
resource "aws_instance" "my_instance" {
  ami = "ami-0773391ae604c49a4"    # Ubuntu 16.04 LTSLinux 2 AMI (region-specific)
  instance_type = "t2.micro"

  tags {
    Name = "My Instance"
  }
}
````

Und anwenden:

    terraform apply



## Über Security Group erreichbar machen

`main.tf`-Datei um folgendes ergänzen:
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
  security_groups = ["${aws_security_group.my_security_group.name}"]
}

output "dns" {
  value = "${aws_instance.my_instance.public_dns}"
}
````

Dann

    terraform apply


Wenn der Befehl erfolgreich durchgeführt wurde, wird `public_dns` ausgegeben, der öffentliche Name der Instanz. Diesen können wir pingen:

    ping <public_dns>


## Web-App provisionieren

Wir wollen auf der EC2-Instanz einen Nginx starten, um zu demonstrieren, wie man allgemein eine Web-App deployen würde.

Hierfür eine Datei namens `userdata.sh` mit folgendem Inhalt erstellen:

````
#!/bin/sh

sudo apt-get -y update
sudo apt-get -y install nginx
sudo service nginx start
````

und in der EC2-Instanz als AWS User Data (d.h. als automatisch ausgeführtes Startup-Skript) einbinden:

````
resource "aws_instance" "my_instance" {
  ...
  user_data              = "${file("userdata.sh")}"
}
````

Nginx startet standardmäßig auf Port 80. Um ihn von außen erreichbar zu machen, erweitern wir unsere Security Group. Zusätzlich erlauben wir ausgehenden Internet Traffic, um per apt-get nginx überhaupt herunterladen zu können:

````
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
````

Mit `terraform apply` setzen wir die Änderungen um:

    terraform apply

## Aufräumen

Damit keine Kosten entstehen:

    terraform destroy