# ... (content from security_groups.tf) 

# Security groups have been moved to the security module
# This file is kept for backwards compatibility but will be removed 

############################
# Bastion SG
############################

resource "aws_security_group" "bastion" {
  name        = "bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "bastion-sg" })
}

############################
# ALB SG (Jenkins)
############################

resource "aws_security_group" "alb_jenkins" {
  name        = "jenkins-alb-sg"
  description = "Public ALB for Jenkins access"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "jenkins-alb-sg" })
}

############################
# ALB SG (SonarQube)
############################

resource "aws_security_group" "alb_sonar" {
  name        = "sonarqube-alb-sg"
  description = "Public ALB for SonarQube access"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "sonarqube-alb-sg" })
}

############################
# Jenkins Master SG
############################

resource "aws_security_group" "jenkins_master" {
  name        = "jenkins-master-sg"
  description = "SG for Jenkins master EC2 instance"
  vpc_id      = aws_vpc.this.id

  # UI from ALB
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_jenkins.id]
    description     = "UI traffic from ALB"
  }

  # SSH from bastion
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
    description     = "SSH from bastion"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "jenkins-master-sg" })
}

############################
# Jenkins Worker SG
############################

resource "aws_security_group" "jenkins_worker" {
  name        = "jenkins-worker-sg"
  description = "SG for Jenkins workers"
  vpc_id      = aws_vpc.this.id

  # SSH from bastion
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
    description     = "SSH from bastion"
  }

  # Allow SonarQube traffic from the SonarQube ALB
  ingress {
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sonar.id]
    description     = "SonarQube traffic from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "jenkins-worker-sg" })
}

############################
# EKS Nodes SG
############################

resource "aws_security_group" "eks_nodes" {
  name        = "eks-nodes-sg"
  description = "SG for EKS worker nodes"
  vpc_id      = aws_vpc.this.id

  # Allow all within the node group
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "All traffic within the node SG"
  }

  # SSH from bastion
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
    description     = "SSH from bastion"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "eks-nodes-sg" })
}

############################
# RDS SG
############################

resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "SG for PostgreSQL RDS"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
    description     = "Postgres from EKS nodes"
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
    description     = "Postgres from Bastion"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "rds-sg" })
}

# Stand-alone rules to avoid SG dependency cycle
resource "aws_security_group_rule" "jenkins_master_from_worker_agent" {
  type                     = "ingress"
  security_group_id        = aws_security_group.jenkins_master.id
  source_security_group_id = aws_security_group.jenkins_worker.id
  from_port                = 50000
  to_port                  = 50000
  protocol                 = "tcp"
  description              = "Agent (JNLP) connections from worker to master"
}

resource "aws_security_group_rule" "jenkins_worker_ssh_from_master" {
  type                     = "ingress"
  security_group_id        = aws_security_group.jenkins_worker.id
  source_security_group_id = aws_security_group.jenkins_master.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  description              = "SSH from master to worker"
} 