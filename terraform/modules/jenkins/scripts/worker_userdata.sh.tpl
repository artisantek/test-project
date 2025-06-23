#!/bin/bash
set -euxo pipefail

# Install Java
apt-get update
apt-get install -y openjdk-17-jre

# Install Docker
apt-get install -y docker.io
systemctl enable --now docker
usermod -aG docker ubuntu

# Run SonarQube if not running
if ! docker ps -a --format '{{.Names}}' | grep -q "^sonar$"; then
  docker run -d --name sonar -p 9000:9000 --restart always sonarqube:lts-community
fi

# Install Trivy
apt-get install -y wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/trivy.list
apt-get update
apt-get install -y trivy

# Install Snyk
curl --create-dirs -fsSL https://static.snyk.io/cli/latest/snyk-linux -o /usr/local/bin/snyk
chmod +x /usr/local/bin/snyk

# Install kubectl
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -fsSL "https://dl.k8s.io/release/$${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl

# Install AWS CLI
apt-get install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip

# Install Helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Configure kubectl for the ubuntu user
su - ubuntu -c "aws eks update-kubeconfig --region ${region} --name ${cluster_name}" 