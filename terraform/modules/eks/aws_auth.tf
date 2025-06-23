resource "kubernetes_config_map_v1_data" "aws_auth" {
  provider = kubernetes.eks

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(concat(
      # Default node group role
      [{
        rolearn  = aws_iam_role.node_role.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }],
      # Add bastion role if provided
      var.bastion_role_arn != null ? [{
        rolearn  = var.bastion_role_arn
        username = "bastion-user"
        groups   = ["system:masters"]
      }] : [],
      # Add Jenkins agent role if provided
      var.jenkins_agent_role_arn != null ? [{
        rolearn  = var.jenkins_agent_role_arn
        username = "jenkins-agent"
        groups   = ["system:masters"]
      }] : []
    ))
    mapUsers = yamlencode([])
  }

  force = true # Overwrite the data field

  depends_on = [aws_eks_node_group.default]
} 