# Terraform Infrastructure - Modular Architecture

This Terraform configuration sets up a complete AWS infrastructure using a modular approach for better organization and maintainability.

## Architecture Overview

This infrastructure creates:
- **VPC Module**: Network infrastructure with multi-AZ subnets
- **EKS Module**: Kubernetes cluster with worker nodes
- **Jenkins Module**: CI/CD infrastructure with master/worker setup
- **Bastion Module**: Secure access point for private resources
- **RDS Module**: PostgreSQL database in private subnets

## Module Organization

### IAM Resource Placement Strategy

We follow this logical organization for IAM resources:

1. **EKS-specific IAM roles** → `eks` module
   - EKS cluster service role
   - EKS node group role
   - Required policy attachments

2. **Cross-service IAM policies** → `security` module
   - EKS read-only policy (used by Jenkins and Bastion)
   - Shared security policies

3. **Service-specific IAM roles** → Respective modules
   - Jenkins agent roles → `jenkins` module
   - Bastion instance role → `bastion` module

This approach ensures:
- **Logical separation**: IAM resources are where they logically belong
- **Reusability**: Shared policies are centralized in security module
- **Maintainability**: Each module manages its own service-specific roles

## Directory Structure

```
terraform/
├── main.tf                 # Root module configuration
├── variables.tf            # Input variables
├── outputs.tf             # Output values
├── providers.tf           # Provider configuration
├── terraform.tf          # Terraform settings
└── modules/
    ├── vpc/               # Network infrastructure
    │   ├── vpc.tf
    │   ├── subnets.tf
    │   ├── routes.tf
    │   ├── nat.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security/          # Security groups & shared IAM
    │   ├── security_groups.tf
    │   ├── iam_policies.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── providers.tf
    ├── eks/               # Kubernetes cluster
    │   ├── cluster.tf
    │   ├── nodegroup.tf
    │   ├── iam.tf         # EKS-specific IAM roles
    │   ├── aws_auth.tf
    │   ├── alb_controller.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── providers.tf
    ├── jenkins/           # CI/CD infrastructure
    ├── bastion/           # Secure access point
    └── rds/               # Database
```

## Key Features

### Networking (VPC Module)
- Multi-AZ setup with public, private, and data subnets
- NAT Gateways for outbound internet access from private subnets
- Proper route table associations
- EKS-compatible subnet tagging

### Security (Security Module)
- Dedicated security groups for each service
- Principle of least privilege access
- Cross-reference between security groups for controlled access
- Centralized IAM policies for shared access patterns

### EKS (EKS Module)
- Latest Kubernetes version support
- Managed node groups with auto-scaling
- ALB Ingress Controller integration
- AWS Load Balancer Controller with pod identity
- Proper RBAC configuration

## Usage

### Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- kubectl installed (for cluster management)

### Deployment

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Review the plan:**
   ```bash
   terraform plan
   ```

3. **Apply the configuration:**
   ```bash
   terraform apply
   ```

4. **Configure kubectl for EKS:**
   ```bash
   aws eks update-kubeconfig --region ap-south-1 --name movie-eks
   ```

### Customization

Edit `terraform.tfvars` to customize:
```hcl
project_name = "your-project"
vpc_cidr     = "10.0.0.0/16"
region       = "ap-south-1"
environment  = "dev"

# Jenkins Configuration
jenkins_master_ami = "ami-xxxxxxxxx"
jenkins_worker_ami = "ami-xxxxxxxxx"
jenkins_acm_cert_arn = "arn:aws:acm:..."

# Bastion Configuration  
bastion_ami = "ami-xxxxxxxxx"
```

## Outputs

The configuration provides these key outputs:
- VPC ID and subnet IDs
- EKS cluster endpoint and certificate
- RDS instance endpoint
- Security group IDs
- NAT Gateway IPs

## Security Best Practices

1. **Network Segmentation**: Resources are placed in appropriate subnet tiers
2. **Security Groups**: Minimal required access between components
3. **IAM Roles**: Service-specific roles with minimal required permissions
4. **Encryption**: EKS uses AWS managed encryption
5. **Private Access**: Database and worker nodes are in private subnets

## Maintenance

### Adding New Services
1. Create a new module directory under `modules/`
2. Define service-specific IAM roles within the module
3. Reference shared policies from the security module
4. Add module call in `main.tf`

### Updating Security Rules
- Security group modifications go in `modules/security/security_groups.tf`
- Shared IAM policies go in `modules/security/iam_policies.tf`

## Troubleshooting

### Common Issues
1. **IAM Permission Errors**: Ensure your AWS credentials have sufficient permissions
2. **Resource Limits**: Check AWS service quotas in your region
3. **Subnet CIDR Conflicts**: Ensure VPC CIDR doesn't conflict with existing networks

### Validation
```bash
# Validate configuration
terraform validate

# Check formatting
terraform fmt -check

# Security scan
tfsec .
```
