provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "terra-sample0" {
  	ami 		= "ami-04169656fea786776"
  	instance_type	= "t2.nano"
        user_data              = <<-EOF
		#!/bin/bash
		echo "test" > index.html
                echo '{"health": "ok"}' > health
		nohup busybox httpd -f -p 80 &
	EOF 

        vpc_security_group_ids = [
          "${aws_security_group.http-group.id}",
          "${aws_security_group.https-group.id}",
          "${aws_security_group.ssh-group.id}",
          "${aws_security_group.all-outbound-traffic.id}",
        ]
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.terra-sample0.id}"
}

resource "aws_security_group" "https-group" {
  name = "https-access-group"
  description = "Allow traffic on port 443 (HTTPS)"

  tags = {
    Name = "HTTPS Inbound Traffic Security Group"
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}


resource "aws_security_group" "http-group" {
  name = "http-access-group"
  description = "Allow traffic on port 80 (HTTP)"

  tags = {
    Name = "HTTP Inbound Traffic Security Group"
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_security_group" "all-outbound-traffic" {
  name = "all-outbound-traffic-group"
  description = "Allow traffic to leave the AWS instance"

  tags = {
    Name = "Outbound Traffic Security Group"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_security_group" "ssh-group" {
  name = "ssh-access-group"
  description = "Allow traffic to port 22 (SSH)"

  tags = {
    Name = "SSH Access Security Group"
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}


output "ip" {
  value = "${aws_eip.ip.public_ip}"
}
