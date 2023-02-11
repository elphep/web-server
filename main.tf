terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_security_group" "web-server-sg" {
  name        = "web-server-sg-tf"
  description = "Allow SSh from aws instance connect, http and https"

  ingress {
    description      = "https"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["13.239.158.0/29"]
  }

  ingress {
    description      = "80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web-server-terraform" {
  ami           = "ami-00b23d395f228131f"
  instance_type = "t2.micro"

  tags = {
    Name = "web-server-terraform"
  }

  user_data = "${file("web-server-userdata.sh")}"

}

resource "aws_eip" "web-server-eip" {
  vpc = false
  tags = {
    "Name" = "webServerEIP"
  }
}

resource "aws_eip_association" "eip-association" {
  instance_id   = aws_instance.web-server-terraform.id
  allocation_id = aws_eip.web-server-eip.id
}

resource "aws_network_interface_sg_attachment" "sg-attachment" {
  security_group_id    = aws_security_group.web-server-sg.id
  network_interface_id = aws_instance.web-server-terraform.primary_network_interface_id
}
