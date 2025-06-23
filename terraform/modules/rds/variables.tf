variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.10"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for DB subnet group"
  type        = list(string)
}

variable "db_sg_id" {
  description = "Security group ID for database"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
} 