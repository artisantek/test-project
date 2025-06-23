variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for ALB"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for Jenkins EC2 instances"
}

variable "alb_sg_id" {
  type        = string
  description = "Security group ID for ALB"
}

variable "master_sg_id" {
  type        = string
  description = "Security group ID for Jenkins master"
}

variable "worker_sg_id" {
  type        = string
  description = "Security group ID for Jenkins workers"
}

variable "master_instance_type" {
  type        = string
  default     = "t3.medium"
}

variable "master_ami_id" {
  type        = string
  description = "AMI ID for Jenkins master EC2"
}

variable "worker_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "worker_ami_id" {
  type        = string
  description = "AMI ID for Jenkins worker EC2"
}

variable "tags" {
  type        = map(string)
  default     = {}
}

variable "certificate_arn" {
  type        = string
  description = "ARN of ACM certificate for HTTPS"
}

variable "eks_policy_arn" {
  description = "ARN of the IAM policy to attach for EKS access"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of an existing EC2 KeyPair to enable SSH access to the Jenkins instances."
  type        = string
  default     = null
}

variable "region" {
  description = "AWS Region for the EKS cluster"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster to configure access for"
  type        = string
}

variable "alb_sonar_sg_id" {
  type        = string
  description = "Security group ID for the SonarQube ALB"
} 