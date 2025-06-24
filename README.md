# Movie Analyzer Application DevOps Project

This repository contains the source code and infrastructure configuration files for the Tetris Application DevOps Project. The project aims to demonstrate the end-to-end Continuous Integration and Continuous Deployment (CI/CD) pipeline for the Tetris game application.

## Repository Structure

The repository is organized into the following main folders:

1. **Terraform**: Contains Terraform configuration files to set up the required infrastructure, including EKS (Elastic Kubernetes Service), Jenkins Master, Jenkins Agent, RDS and Networking
3. **movie-analyzer-app**: Contains the source code of Movie Analyzer application along with Helm charts and other related files.

## Prerequisites

Before proceeding with the project, ensure that you have the following prerequisites:

- AWS Account and Access Keys
- Terraform installed
- Snyk Account

## Getting Started

Follow these steps to set up the project:

## Terraform

Terraform is used to automate the creation and management of infrastructure as code. It supports multiple providers such as AWS, Google Cloud, Azure, etc.

### Configuration Steps:

1. Configure AWS credentials using AWS CLI.
2. Navigate to each folder to create resources:
   - `terraform init` - Initialize the directory.
   - `terraform plan` - Display the execution plan.
   - `terraform apply` - Apply the configuration.

## Jenkins

Jenkins is an open-source automation server that enables developers around the world to reliably build, test, and deploy their software. It offers hundreds of plugins to support building, deploying, and automating any project.

### Accessing Jenkins

Access the Jenkins server using the following URL: 
```
http://<jenkins-master-public-url>
```

## Jenkins Configuration

### 1. Credentials

Jenkins requires the setup of several credentials to facilitate CI/CD processes:

- **githubCred**: Contains GitHub username and Git Token.
- **snykCred**: Contains Snyk Auth Token.
- **sonarToken**: Contains SonarQube Token.

Navigate to **Jenkins Dashboard** > **Manage Jenkins** > **Manage Credentials** to add these credentials.

### 2. Jenkins Agent

Connect the Jenkins Agent created via Terraform to the Jenkins Master. This setup involves configuring the agent in **Manage Nodes and Clouds** in the Jenkins settings.

### 3. Plugins

Install essential Jenkins plugins:

- **Sonar Scanner**: For SonarQube integration and code quality checks.
- **Blue Ocean** (Optional): For enhanced CI/CD pipeline visualization.
- **Multibranch Scan Webhook Trigger**: For Jenkins Webhook Trigger for Multi Branch Pipeline.

Navigate to **Manage Jenkins** > **Manage Plugins** to install these.

### 4. Shared Libraries

Configure Jenkins to use shared libraries for pipeline scripts:

- Go to **Manage Jenkins** > **System Configuration** > **Configure System**.
- Under **Global Pipeline Libraries**, add the library with the repository URL: https://github.com/artisantek/jenkins-sharedlibraries


### 5. SonarQube Integration

SonarQube is a static code analysis tool that helps in identifying bugs, vulnerabilities, and code smells in your source code.

#### Configuration Steps:

- Connect to the SonarQube server running in the container at: 
```
http://<jenkins-agent-public-url>
```

Initial credentials are `admin` for both username and password.

##### Generate Sonar Token:
- Navigate to **Administration** > **Security** > **Users**.
- Update tokens and add this token as a credential in Jenkins.

##### Quality Gate Configuration:
- Go to **Administration** > **Configuration** > **Webhook**.
- Create a webhook with the URL:
  ```
  http://<jenkins-public-url>/sonarqube-webhook/
  ```

##### SonarQube Scanner Installation:
- Navigate to **Manage Jenkins** > **Global Tool Configuration**.
- Click on **Add SonarQube Scanner** and configure with:
  - Name: `sonar-scanner`
  - **Install Automatically**

##### Integrate SonarQube Server:
- Navigate to **Manage Jenkins** > **Configure System** > **SonarQube Servers**.
- Click on **add SonarQube** and configure with:
  - Name: `sonar-server`
  - Server URL: `http://<jenkins-agent-public-url>`
  - Server Authentication Token: `sonarToken Cred`

### 6. Multi-Branch Pipeline

Set up a Multi-Branch Pipeline to automatically build branches and pull requests:

- Navigate to **Jenkins Dashboard** > **New Item**.
- Select **Multibranch Pipeline** and configure source repository and branch discovery behaviors.


