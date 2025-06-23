output "public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Public IP address of the bastion host"
}

output "role_arn" {
  value       = aws_iam_role.bastion_eks_role.arn
  description = "ARN of the IAM role for the bastion host"
} 