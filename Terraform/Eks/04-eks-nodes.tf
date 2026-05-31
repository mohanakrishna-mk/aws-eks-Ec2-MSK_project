# EKS NODE GROUP
#################################################

resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "private-workers"

  node_role_arn = aws_iam_role.worker_nodes.arn

  subnet_ids = [
    aws_subnet.worker_1.id,
    aws_subnet.worker_2.id
  ]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 5
  }

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = "$Latest"
  }

  capacity_type = "ON_DEMAND"

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy
  ]
}



resource "aws_security_group" "worker_node_sg" {
  name   = "eks-worker-node-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    self      = true
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}