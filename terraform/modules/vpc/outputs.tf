output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for s in aws_subnet.private : s.id]
}

output "data_subnet_ids" {
  description = "List of data subnet IDs"
  value       = [for s in aws_subnet.data : s.id]
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = [for ngw in aws_nat_gateway.nat : ngw.id]
}

# Security group outputs have been moved to the security module 

output "bastion_sg_id" {
  description = "Security group ID for bastion host"
  value       = aws_security_group.bastion.id
}

output "alb_jenkins_sg_id" {
  description = "Security group ID for Jenkins ALB"
  value       = aws_security_group.alb_jenkins.id
}

output "jenkins_master_sg_id" {
  description = "Security group ID for Jenkins master"
  value       = aws_security_group.jenkins_master.id
}

output "jenkins_worker_sg_id" {
  description = "Security group ID for Jenkins workers"
  value       = aws_security_group.jenkins_worker.id
}

output "eks_nodes_sg_id" {
  description = "Security group ID for EKS worker nodes"
  value       = aws_security_group.eks_nodes.id
}

output "rds_sg_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.rds.id
}

output "eks_read_only_policy_arn" {
  description = "ARN of the EKS read-only policy"
  value       = aws_iam_policy.eks_read_only.arn
}

output "alb_sonar_sg_id" {
  description = "Security group ID for SonarQube ALB"
  value       = aws_security_group.alb_sonar.id
} 