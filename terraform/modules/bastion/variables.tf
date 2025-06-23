variable "subnet_id" {
  description = "Public subnet ID for the bastion instance"
  type        = string
}

variable "sg_id" {
  description = "Security group ID for the bastion instance"
  type        = string
}

variable "ami_id" {
  description = "AMI to use for the bastion instance"
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "eks_policy_arn" {
  description = "ARN of the IAM policy to attach for EKS access"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of an existing EC2 KeyPair to enable SSH access to the bastion."
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