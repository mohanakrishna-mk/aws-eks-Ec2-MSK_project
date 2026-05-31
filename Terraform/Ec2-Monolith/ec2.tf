

# ======================================================
# REACT FRONTEND SERVER
# ======================================================

resource "aws_instance" "ec2_react_frontend_server" {
  ami                         = "ami-03f4878755434977f"
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.ec2_public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2_key.key_name

  root_block_device {
    volume_size = 20
  }

  user_data = <<-EOF
#!/bin/bash

apt update -y
apt install nginx -y

systemctl enable nginx
systemctl start nginx
EOF

  tags = {
    Name    = "EC2-React-Frontend-Server"
    Project = "EC2"
  }
}

# ======================================================
# NODEJS BACKEND SERVER
# ======================================================

resource "aws_instance" "ec2_nodejs_backend_server" {
  ami                         = "ami-03f4878755434977f"
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.ec2_public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2_key.key_name

  root_block_device {
    volume_size = 20
  }

  user_data = <<-EOF
#!/bin/bash

apt update -y

curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

apt install -y nodejs nginx

npm install -g pm2

systemctl enable nginx
systemctl start nginx
EOF

  tags = {
    Name    = "EC2-NodeJS-Backend-Server"
    Project = "EC2"
  }
}

# ======================================================
# JAVA BACKEND SERVER
# ======================================================

resource "aws_instance" "ec2_java_backend_server" {
  ami                         = "ami-03f4878755434977f"
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.ec2_public_subnet_2.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2_key.key_name

  root_block_device {
    volume_size = 20
  }

  user_data = <<-EOF
#!/bin/bash

apt update -y

apt install openjdk-17-jdk nginx -y

systemctl enable nginx
systemctl start nginx
EOF

  tags = {
    Name    = "EC2-Java-Backend-Server"
    Project = "EC2"
  }
}

# ======================================================
# MONGODB SERVER
# ======================================================

resource "aws_instance" "ec2_mongodb_server" {
  ami                         = "ami-03f4878755434977f"
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.ec2_public_subnet_2.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2_key.key_name

  root_block_device {
    volume_size = 30
  }

  user_data = <<-EOF
#!/bin/bash

apt update -y

apt install mongodb -y

systemctl enable mongodb
systemctl start mongodb
EOF

  tags = {
    Name    = "EC2-MongoDB-Server"
    Project = "EC2"
  }
}

# ======================================================
# ELASTIC IP - REACT
# ======================================================

resource "aws_eip" "ec2_react_eip" {
  domain = "vpc"

  tags = {
    Name    = "EC2-React-EIP"
    Project = "EC2"
  }
}

resource "aws_eip_association" "ec2_react_eip_assoc" {
  instance_id   = aws_instance.ec2_react_frontend_server.id
  allocation_id = aws_eip.ec2_react_eip.id
}

# ======================================================
# ELASTIC IP - NODEJS
# ======================================================

resource "aws_eip" "ec2_nodejs_eip" {
  domain = "vpc"

  tags = {
    Name    = "EC2-NodeJS-EIP"
    Project = "EC2"
  }
}

resource "aws_eip_association" "ec2_nodejs_eip_assoc" {
  instance_id   = aws_instance.ec2_nodejs_backend_server.id
  allocation_id = aws_eip.ec2_nodejs_eip.id
}

# ======================================================
# ELASTIC IP - JAVA
# ======================================================

resource "aws_eip" "ec2_java_eip" {
  domain = "vpc"

  tags = {
    Name    = "EC2-Java-EIP"
    Project = "EC2"
  }
}

resource "aws_eip_association" "ec2_java_eip_assoc" {
  instance_id   = aws_instance.ec2_java_backend_server.id
  allocation_id = aws_eip.ec2_java_eip.id
}
