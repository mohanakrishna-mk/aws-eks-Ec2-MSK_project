#################################################
# IAM ROLE FOR BASTION
#################################################

resource "aws_iam_role" "bastion_role" {
  name = "eks-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_worker" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

#################################################
# IAM POLICY ATTACHMENTS
#################################################





#################################################
# INSTANCE PROFILE
#################################################

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "eks-bastion-profile"
  role = aws_iam_role.bastion_role.name
}

#################################################
# BASTION EC2
#################################################

resource "aws_instance" "bastion" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = "t3.micro"

  subnet_id              = aws_subnet.public_1.id

  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]

  associate_public_ip_address = true

  key_name = "ec2-key"

  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name

  #################################################
  # INSTALL TOOLS
  #################################################

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y unzip curl tar

              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              ./aws/install

              #snap install k9s -y
              curl -sS https://webi.sh/k9s | sh
              source ~/.config/envman/PATH.env



              curl -LO https://dl.k8s.io/release/v1.33.0/bin/linux/amd64/kubectl
              chmod +x kubectl
              mv kubectl /usr/local/bin/

              curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz"
              tar -xzf eksctl_Linux_amd64.tar.gz -C /tmp
              mv /tmp/eksctl /usr/local/bin/

              curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
              
              alias k=kubectl

              EOF

  tags = {
    Name = "eks-bastion"
  }
}

#################################################
# SECURITY GROUP
#################################################

resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"

  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH"

    from_port = 22
    to_port   = 22

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "bastion-sg"
  }
}

#################################################
# EKS ACCESS ENTRY
#################################################
resource "aws_eks_access_entry" "bastion_access" {
  cluster_name  = aws_eks_cluster.main.name

  principal_arn = aws_iam_role.bastion_role.arn

  type = "STANDARD"
}

resource "aws_eks_access_policy_association" "bastion_admin" {
  cluster_name  = aws_eks_cluster.main.name

  principal_arn = aws_iam_role.bastion_role.arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

#################################################
# OUTPUTS
#################################################

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_instance_id" {
  description = "Instance ID of the bastion host"
  value       = aws_instance.bastion.id
}

