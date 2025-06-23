############################
# IAM Role for EKS Access
############################
resource "aws_iam_role" "bastion_eks_role" {
  name = "bastion-eks-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = var.tags
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion-instance-profile"
  role = aws_iam_role.bastion_eks_role.name
}

############################
# Bastion Host EC2
############################
resource "aws_instance" "bastion" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [var.sg_id]
  iam_instance_profile   = aws_iam_instance_profile.bastion_profile.name
  user_data = templatefile("${path.module}/scripts/setup.sh.tpl", {
    region       = var.region
    cluster_name = var.cluster_name
  })

  tags = merge(var.tags, {
    Name = "bastion-host"
  })
}

resource "aws_iam_role_policy_attachment" "bastion_eks_access" {
  role       = aws_iam_role.bastion_eks_role.name
  policy_arn = var.eks_policy_arn
}

resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = aws_iam_role.bastion_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
} 