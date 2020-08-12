# AWS as provider
provider "aws" {
  region     = "us-east-1"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_instance" "myec2" {
  ami  = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  tags = var.tags
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id = "${aws_subnet.private.id}"
  user_data = "${file("install_jenkins.sh")}"
}


/*
  NAT instance
*/
resource "aws_instance" "nat" {
    ami  = var.ami
    instance_type = var.instance_type
    key_name = var.key_name
    vpc_security_group_ids = ["${aws_security_group.nat.id}"]
    subnet_id = "${aws_subnet.public.id}"
    associate_public_ip_address = true
    source_dest_check = false
    tags = var.tags
}

resource "aws_eip" "nat" {
    instance = "${aws_instance.nat.id}"
    vpc = true
}
/*
  VPC to IGW
*/
resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr_block
  tags = var.tags
  # enable_dns_hostnames = true
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.myvpc.id
}


/*
  NAT Instance security group
*/

resource "aws_security_group" "nat" {
  name = "myec2_nat_sg"

  description = "NAT security group"
  vpc_id      = aws_vpc.myvpc.id
  tags = var.tags

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Telnet"
    cidr_blocks = ["0.0.0.0/0"]  # your Laptop IP
  }
 ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    description = "HTTPS"
    cidr_blocks = ["0.0.0.0/0"]  # your Laptop IP
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 22
    to_port     = 22
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
}

/*
  EC2 Instance security group
*/

resource "aws_security_group" "ec2" {
  name = "myec2_sg"

  description = "Ec2 security group"
  vpc_id      = aws_vpc.myvpc.id
  tags = var.tags

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Telnet"
    cidr_blocks = ["0.0.0.0/0"]  # your laptop IP
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    description = "HTTPS"
    security_groups = ["${aws_security_group.nat.id}"]
  }


  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 22
    to_port     = 22
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
}


/*
  Public Subnet
*/
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.pubsubnet_cidr_block
  availability_zone = "us-east-1a"
  # map_public_ip_on_launch = true
}
/*
  Public route table
*/
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

/*
  Private Subnet
*/
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.privatesubnet_cidr_block
  availability_zone = "us-east-1a"
  # map_public_ip_on_launch = true
}

/*
  Private route table
*/

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    instance_id = aws_instance.nat.id
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}



