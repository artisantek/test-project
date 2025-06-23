############################################
# AWS Load Balancer Controller (inside EKS module)
############################################

# Read cluster info after cluster is created

## Cluster data & providers are defined in cluster.tf and reused here.

############################################
# IAM setup (OIDC provider, policy, role)
############################################

data "tls_certificate" "oidc_thumbprint" {
  url       = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  depends_on = [aws_eks_cluster.cluster]
}

resource "aws_iam_openid_connect_provider" "oidc" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_thumbprint.certificates[0].sha1_fingerprint]
}

data "http" "alb_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.13.3/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "alb_controller" {
  name   = "${var.cluster_name}-alb-controller-policy"
  policy = data.http.alb_policy.response_body
}

resource "aws_iam_role" "alb_sa_role" {
  name = "${var.cluster_name}-alb-sa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.oidc.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_sa_role.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

############################################
# Kubernetes SA & Helm chart
############################################

resource "kubernetes_service_account" "alb_controller_sa" {
  provider = kubernetes.eks

  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_sa_role.arn
    }
  }
}

resource "helm_release" "alb_controller" {
  provider = helm.eks

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  values = [yamlencode({
    region      = var.region
    vpcId       = var.vpc_id
    clusterName = var.cluster_name
    serviceAccount = {
      create = false
      name   = kubernetes_service_account.alb_controller_sa.metadata[0].name
    }
  })]

  depends_on = [kubernetes_service_account.alb_controller_sa]
} 