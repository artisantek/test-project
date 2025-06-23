output "alb_dns_name" {
  value = aws_lb.jenkins.dns_name
}

output "jenkins_agent_role_arn" {
  description = "ARN of the IAM role for the Jenkins agent"
  value       = aws_iam_role.jenkins_agent_eks_role.arn
}

output "sonarqube_alb_dns_name" {
  value = aws_lb.sonarqube.dns_name
} 