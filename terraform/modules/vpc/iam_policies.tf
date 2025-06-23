############################
# Cross-Service IAM Policies
############################

resource "aws_iam_policy" "eks_read_only" {
  name        = "eks-read-only-access"
  description = "Allows read-only access to EKS cluster information"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "eks:DescribeCluster",
        "eks:ListClusters"
      ],
      Effect   = "Allow",
      Resource = "*"
    }]
  })
  
  tags = var.tags
} 