############################
# Jenkins Master EC2
############################

resource "aws_instance" "jenkins_master" {
  ami                    = var.master_ami_id
  instance_type          = var.master_instance_type
  key_name               = var.ssh_key_name
  subnet_id              = element(var.private_subnet_ids, 0)
  vpc_security_group_ids = [var.master_sg_id]
  user_data              = file("${path.module}/scripts/master_userdata.sh")

  tags = merge(var.tags, {
    Name = "jenkins-master"
  })
}

############################
# Jenkins Worker EC2
############################

resource "aws_instance" "jenkins_worker" {
  ami                    = var.worker_ami_id
  instance_type          = var.worker_instance_type
  key_name               = var.ssh_key_name
  subnet_id              = element(var.private_subnet_ids, 1)
  vpc_security_group_ids = [var.worker_sg_id]
  user_data = templatefile("${path.module}/scripts/worker_userdata.sh.tpl", {
    region       = var.region
    cluster_name = var.cluster_name
  })
  iam_instance_profile   = aws_iam_instance_profile.jenkins_agent_profile.name

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  tags = merge(var.tags, {
    Name = "jenkins-worker"
  })
}

############################
# ALB & Target Group
############################

resource "aws_lb" "jenkins" {
  name               = "jenkins-alb"
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  tags = var.tags
}

resource "aws_lb_target_group" "jenkins_http" {
  name     = "jenkins-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/login"
    matcher             = "200-399"
  }

  tags = var.tags
}

resource "aws_lb_listener" "jenkins_https" {
  load_balancer_arn = aws_lb.jenkins.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_http.arn
  }
}

resource "aws_lb_listener" "jenkins_http" {
  load_balancer_arn = aws_lb.jenkins.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group_attachment" "master_attach" {
  target_group_arn = aws_lb_target_group.jenkins_http.arn
  target_id        = aws_instance.jenkins_master.id
  port             = 8080
}

############################
# SonarQube ALB & Target Group
############################

resource "aws_lb" "sonarqube" {
  name               = "sonarqube-alb"
  load_balancer_type = "application"
  security_groups    = [var.alb_sonar_sg_id]
  subnets            = var.public_subnet_ids

  tags = var.tags
}

resource "aws_lb_target_group" "sonarqube_http" {
  name     = "sonarqube-tg"
  port     = 9000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"

  health_check {
    path    = "/"
    port    = "9000"
    matcher = "200-399"
  }

  tags = var.tags
}

resource "aws_lb_listener" "sonarqube_https" {
  load_balancer_arn = aws_lb.sonarqube.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sonarqube_http.arn
  }
}

resource "aws_lb_listener" "sonarqube_http" {
  load_balancer_arn = aws_lb.sonarqube.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group_attachment" "sonarqube_attach" {
  target_group_arn = aws_lb_target_group.sonarqube_http.arn
  target_id        = aws_instance.jenkins_worker.id
  port             = 9000
}

############################
# IAM Role for Jenkins Agent
############################
resource "aws_iam_role" "jenkins_agent_eks_role" {
  name = "jenkins-agent-eks-role"
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

resource "aws_iam_instance_profile" "jenkins_agent_profile" {
  name = "jenkins-agent-instance-profile"
  role = aws_iam_role.jenkins_agent_eks_role.name
}

resource "aws_iam_role_policy_attachment" "jenkins_agent_eks_access" {
  role       = aws_iam_role.jenkins_agent_eks_role.name
  policy_arn = var.eks_policy_arn
}

resource "aws_iam_role_policy_attachment" "jenkins_agent_ecr_full_access" {
  role       = aws_iam_role.jenkins_agent_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
} 