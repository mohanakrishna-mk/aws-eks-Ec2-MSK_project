
# =========================================================
# VPC
# =========================================================

resource "aws_vpc" "ci_cd_vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name        = "ci-cd-vpc"
    Environment = "dev"
    Project     = "ci-cd"
  }
}

# =========================================================
# INTERNET GATEWAY
# =========================================================

resource "aws_internet_gateway" "ci_cd_igw" {
  vpc_id = aws_vpc.ci_cd_vpc.id

  tags = {
    Name        = "ci-cd-igw"
    Environment = "dev"
    Project     = "ci-cd"
  }
}

# =========================================================
# PUBLIC SUBNET
# =========================================================

resource "aws_subnet" "ci_cd_public_subnet" {
  vpc_id                  = aws_vpc.ci_cd_vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "ci-cd-public-subnet"
    Environment = "dev"
    Project     = "ci-cd"
  }
}

# =========================================================
# ROUTE TABLE
# =========================================================

resource "aws_route_table" "ci_cd_public_rt" {
  vpc_id = aws_vpc.ci_cd_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ci_cd_igw.id
  }

  tags = {
    Name        = "ci-cd-public-rt"
    Environment = "dev"
    Project     = "ci-cd"
  }
}

# =========================================================
# ROUTE TABLE ASSOCIATION
# =========================================================

resource "aws_route_table_association" "ci_cd_public_assoc" {
  subnet_id      = aws_subnet.ci_cd_public_subnet.id
  route_table_id = aws_route_table.ci_cd_public_rt.id
}

# =========================================================
# SECURITY GROUP
# =========================================================

resource "aws_security_group" "ci_cd_sg" {
  name        = "ci-cd-sg"
  description = "CI-CD Security Group"
  vpc_id      = aws_vpc.ci_cd_vpc.id

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
    description = "GitLab"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Nexus"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SonarQube"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ci-cd-sg"
    Environment = "dev"
    Project     = "ci-cd"
  }
}


