############################
# EKS Cluster
############################

resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = [var.eks_nodes_sg_id]

    endpoint_private_access = true
    endpoint_public_access  = true # will be restricted by security group CIDRs later
  }

  tags = var.tags
}

# Fetch cluster details for providers

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.cluster.name
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = aws_eks_cluster.cluster.name
}

resource "aws_security_group_rule" "bastion_to_cluster" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = var.bastion_sg_id
  security_group_id        = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
  description              = "Allow bastion to access the EKS cluster API"
}

resource "aws_security_group_rule" "jenkins_agent_to_cluster" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = var.jenkins_agent_sg_id
  security_group_id        = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
  description              = "Allow Jenkins agent to access the EKS cluster API"
} 