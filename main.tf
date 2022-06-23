provider "aws" {}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable all {}
variable instance_type{}
variable ssh_private_key{}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block

    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone

  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.myapp-vpc.id

    tags = {
        Name = "${var.env_prefix}-igw"
    }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myapp-vpc.id

  route {
    cidr_block = var.all
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.env_prefix}-rt"
  }
}

resource "aws_route_table_association" "pub" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_main_route_table_association" "mainrt" {
  vpc_id = aws_vpc.myapp-vpc.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "myapp-sg" {
  name = "myapp-sg"
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.all]
  }

  ingress {
    from_port = 8081
    to_port = 8081
    protocol = "tcp"
    cidr_blocks = [var.all]
  }

  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = [var.all]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.all]
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

data "aws_ami" "amazon-linux" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.amazon-linux.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = "newkey"

  tags = {
    Name = "${var.env_prefix}-server"
  }
}

resource "null_resource" "configure_server" {
  provisioner "local-exec" {
    working_dir = "./config"
    command = "ansible-playbook --inventory ${aws_instance.myapp-server.public_ip}, --private-key ${var.ssh_private_key} --user ec2-user main.yaml"
  }
}

output "ec2-public-ip" {
  value = aws_instance.myapp-server.public_ip
}