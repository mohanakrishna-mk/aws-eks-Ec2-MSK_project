#################################################
# EKS CLUSTER
#################################################

resource "aws_eks_cluster" "main" {
  name     = "demo-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn

  version = "1.33"

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  vpc_config {
    subnet_ids = [
      aws_subnet.eks_control_1.id,
      aws_subnet.eks_control_2.id
    ]
    security_group_ids = [
    aws_security_group.eks_cluster_sg.id
    ] 

    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

#################################################
# EKS ADDONS
#################################################

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"

  depends_on = [
    aws_eks_cluster.main
  ]
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "coredns"

  depends_on = [
    aws_eks_node_group.workers
  ]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "kube-proxy"

  depends_on = [
    aws_eks_node_group.workers
  ]
}



# EKS CLUSTER SECURITY GROUP
#################################################

resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = aws_vpc.main.id

  #################################################
  # BASTION -> EKS API
  #################################################

  ingress {
    description     = "Bastion access to EKS API"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  #################################################
  # WORKER NODES -> EKS CONTROL PLANE
  #################################################

  ingress {
    description     = "Worker nodes to control plane"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.worker_node_sg.id]
  }

  #################################################
  # OUTBOUND
  #################################################

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}