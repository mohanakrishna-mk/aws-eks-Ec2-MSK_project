# ML DevOps Infrastructure Terraform

provider "aws" {
  region = "ap-south-1"
}

# ======================================================
# VPC
# ======================================================

resource "aws_vpc" "ec2_vpc" {
  cidr_block = "10.2.0.0/16"

  tags = {
    Name    = "EC2-VPC"
    Project = "EC2"
  }
}

# ======================================================
# INTERNET GATEWAY
# ======================================================

resource "aws_internet_gateway" "ec2_igw" {
  vpc_id = aws_vpc.ec2_vpc.id

  tags = {
    Name    = "EC2-IGW"
    Project = "EC2"
  }
}

# ======================================================
# PUBLIC SUBNET 1
# ======================================================

resource "aws_subnet" "ec2_public_subnet_1" {
  vpc_id                  = aws_vpc.ec2_vpc.id
  cidr_block              = "10.2.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "EC2-Public-Subnet-1"
    Project = "EC2"
  }
}

# ======================================================
# PUBLIC SUBNET 2
# ======================================================

resource "aws_subnet" "ec2_public_subnet_2" {
  vpc_id                  = aws_vpc.ec2_vpc.id
  cidr_block              = "10.2.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name    = "EC2-Public-Subnet-2"
    Project = "EC2"
  }
}

# ======================================================
# ROUTE TABLE
# ======================================================

resource "aws_route_table" "ec2_public_rt" {
  vpc_id = aws_vpc.ec2_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ec2_igw.id
  }

  tags = {
    Name    = "EC2-Public-RT"
    Project = "EC2"
  }
}

# ======================================================
# ROUTE TABLE ASSOCIATIONS
# ======================================================

resource "aws_route_table_association" "ec2_public_assoc_1" {
  subnet_id      = aws_subnet.ec2_public_subnet_1.id
  route_table_id = aws_route_table.ec2_public_rt.id
}

resource "aws_route_table_association" "ec2_public_assoc_2" {
  subnet_id      = aws_subnet.ec2_public_subnet_2.id
  route_table_id = aws_route_table.ec2_public_rt.id
}

# ======================================================
# SECURITY GROUP
# ======================================================

resource "aws_security_group" "ec2_sg" {
  name        = "EC2-SG"
  description = "EC2 Security Group"
  vpc_id      = aws_vpc.ec2_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "React Frontend"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NodeJS Backend"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Java Backend"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MongoDB"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.2.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "EC2-SG"
    Project = "EC2"
  }
}

# ======================================================
# KEY PAIR
# ======================================================

resource "aws_key_pair" "ec2_key" {
  key_name   = "EC2-Key"
  public_key = file("~/.ssh/id_rsa.pub")

  tags = {
    Name    = "EC2-Key"
    Project = "EC2"
  }
}