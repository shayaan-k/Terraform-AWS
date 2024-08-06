provider "aws" {
    region = "us-east-1"
    access_key = "my-access-key"
    secret_key = "my access-key"
}

## Create VPC
resource "aws_vpc" "prod_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

## Create Internet Gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.prod_vpc.id
}

## Create Route Table
resource "aws_route_table" "prod_route_table" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "Prod"
  }
}

## Create Subnet
resource "aws_subnet" "subnet-1" {
  vpc_id = aws_vpc.prod_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Prod Subnet"
  }
}

## Create route table association
resource "aws_route_table_association" "association" {
  subnet_id = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod_route_table.id
}

## Create security group
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web Traffic"
  vpc_id      = aws_vpc.prod_vpc.id

}

resource "aws_vpc_security_group_ingress_rule" "allow_web_https" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_web_http" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_web_ssh" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

## Create network interface
resource "aws_network_interface" "web-server-nic" {
  subnet_id = aws_subnet.subnet-1.id
  private_ip = "10.0.1.50"
  security_groups = [aws_security_group.allow_web.id]
}

## Create Elastic IP
resource "aws_eip" "eip" {
  domain = "vpc"
  network_interface = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [ aws_internet_gateway.gateway ]
}

## Create Ubuntu server
resource "aws_instance" "web-server-instance" {
  ami = "ami-085925f297f89fce1"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "main-key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apy update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo My First Web Server > /var/ww/html/index.html'
              EOF
  tags = {
    Name = "web-server"
  }
}