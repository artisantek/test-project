module "networking" {
  source = "./modules/vpc"

  name      = var.project_name
  vpc_cidr  = var.vpc_cidr
  az_count  = 2
  bastion_ingress_cidrs = ["0.0.0.0/0"]
  tags      = var.tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name           = "${var.project_name}-eks"
  subnet_ids             = module.networking.private_subnet_ids
  eks_nodes_sg_id        = module.networking.eks_nodes_sg_id
  kubernetes_version     = "1.32"
  node_instance_type     = "t2.medium"
  vpc_id                 = module.networking.vpc_id
  region                 = var.region
  bastion_role_arn       = module.bastion.role_arn
  jenkins_agent_role_arn = module.jenkins.jenkins_agent_role_arn
  ssh_key_name           = aws_key_pair.generated_key.key_name
  bastion_sg_id          = module.networking.bastion_sg_id
  jenkins_agent_sg_id    = module.networking.jenkins_worker_sg_id

  tags = var.tags
}

module "rds" {
  source = "./modules/rds"

  db_name    = var.db_name
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.data_subnet_ids
  db_sg_id   = module.networking.rds_sg_id
  tags       = var.tags
}

module "jenkins" {
  source = "./modules/jenkins"

  vpc_id              = module.networking.vpc_id
  public_subnet_ids   = module.networking.public_subnet_ids
  private_subnet_ids  = module.networking.private_subnet_ids
  alb_sg_id           = module.networking.alb_jenkins_sg_id
  master_sg_id        = module.networking.jenkins_master_sg_id
  worker_sg_id        = module.networking.jenkins_worker_sg_id
  alb_sonar_sg_id     = module.networking.alb_sonar_sg_id
  ssh_key_name        = aws_key_pair.generated_key.key_name

  master_ami_id       = var.jenkins_master_ami
  worker_ami_id       = var.jenkins_worker_ami
  certificate_arn     = var.jenkins_acm_cert_arn
  eks_policy_arn      = module.networking.eks_read_only_policy_arn
  region              = var.region
  cluster_name        = module.eks.cluster_name

  tags = var.tags
}

module "bastion" {
  source = "./modules/bastion"

  subnet_id     = element(module.networking.public_subnet_ids, 0)
  sg_id         = module.networking.bastion_sg_id
  ami_id        = var.bastion_ami
  instance_type = "t2.micro"
  eks_policy_arn = module.networking.eks_read_only_policy_arn
  ssh_key_name  = aws_key_pair.generated_key.key_name
  region         = var.region
  cluster_name   = module.eks.cluster_name

  tags = var.tags
}

resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.project_name}-ssh-key"
  public_key = tls_private_key.generated_key.public_key_openssh
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.generated_key.private_key_pem
  filename        = "${path.module}/tf-generated-key.pem"
  file_permission = "0400"
}
