#!/bin/bash
set -euxo pipefail

# Install Java & Jenkins
apt-get update
apt-get install -y openjdk-17-jre
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
apt-get update
apt-get install -y jenkins

# Wait for password file to be created
PASSWORD_FILE="/var/lib/jenkins/secrets/initialAdminPassword"
while [ ! -f "$PASSWORD_FILE" ]; do
  sleep 5
done

# Store password in SSM Parameter Store
PASSWORD=$(cat $PASSWORD_FILE)
aws ssm put-parameter --name "/jenkins/initialAdminPassword" --value "$PASSWORD" --type "SecureString" --overwrite --region "${region}" 