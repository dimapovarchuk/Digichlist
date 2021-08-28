terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  shared_credentials_file = "credentials.txt"
  profile                 = "customprofile"
  region                  = "eu-west-1"
}

resource "aws_key_pair" "adminuser" {
  key_name   = "terraform"
  public_key = "..."
}

resource "aws_instance" "app_server01" {
  ami             = "ami-0a8e758f5e873d1c1"
  instance_type   = "t2.medium"
  user_data       = file("digichlist.sh")
  security_groups = ["web-servers", "allow_ssh"]
  key_name        = "terraform"

  tags = {
    Name = "Digichlist"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow inbound SSH"
  }
}

resource "aws_security_group" "web-servers" {
  name        = "web-servers"
  description = "Allow HTTP/S inbound traffic"

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http/s_to_web_servers"
  }
}
