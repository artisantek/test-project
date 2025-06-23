variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs for the cluster and node groups"
  type        = list(string)
}

variable "eks_nodes_sg_id" {
  description = "Security group ID to associate with worker nodes"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.32"
}

variable "node_instance_type" {
  description = "EC2 instance type for node group"
  type        = string
  default     = "t2.medium"
}

variable "desired_capacity" {
  description = "Desired node count"
  type        = number
  default     = 2
}

variable "vpc_id" {
  description = "VPC ID where ALB controller operates"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "bastion_role_arn" {
  description = "ARN of an IAM role to grant EKS access"
  type        = string
  default     = null
}

variable "jenkins_agent_role_arn" {
  description = "ARN of the Jenkins agent IAM role to grant EKS access"
  type        = string
  default     = null
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair to associate with EKS nodes for SSH access. If not provided, key-based SSH is disabled."
  type        = string
  default     = null
}

variable "bastion_sg_id" {
  description = "Security group ID of the bastion host to allow EKS API access."
  type        = string
}

variable "jenkins_agent_sg_id" {
  description = "Security group ID of the Jenkins agent to allow EKS API access."
  type        = string
}

// Note: region and vpc_id variables are no longer required for EKS module (moved to ALB controller). 