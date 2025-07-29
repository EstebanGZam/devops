# Blue-Green Deployment Strategy Laboratory Documentation

## Overview

This document provides comprehensive technical documentation for a hands-on laboratory exercise focused on implementing Blue-Green deployment strategies using Amazon Web Services (AWS), Kubernetes, Jenkins, and supporting DevOps tools. The Blue-Green deployment strategy is a production deployment technique that reduces downtime and risk by running two identical production environments, allowing seamless traffic switching between versions.

## Prerequisites

- AWS Account with appropriate permissions
- Basic understanding of containerization and Kubernetes
- Familiarity with CI/CD concepts
- SSH client for remote server access

## Architecture Overview

The laboratory implements a complete DevOps pipeline incorporating:

- **AWS EC2** instances for infrastructure hosting
- **Amazon EKS** for Kubernetes cluster management
- **Jenkins** for continuous integration and deployment automation
- **Nexus Repository** for artifact management
- **SonarQube** for code quality analysis
- **Trivy** for container vulnerability scanning

## Laboratory Implementation

### Phase 1: AWS Infrastructure Setup

#### 1.1 Initial AWS Access

The laboratory begins with accessing the AWS Management Console to establish the foundational cloud infrastructure required for the Blue-Green deployment environment.

![AWS Console Access](ANNEXES/Pasted%20image%2020250513193241.png)

#### 1.2 Security Group Configuration

A security group serves as a virtual firewall controlling inbound and outbound traffic to EC2 instances. This configuration is critical for maintaining secure communication between components while enabling necessary service accessibility.

![Security Group Creation](ANNEXES/Pasted%20image%2020250513195925.png)

The security group requires specific inbound rules to facilitate proper communication between services. These rules define which protocols, ports, and source IP ranges are permitted to access the instances within the security group.

![Inbound Rules Configuration](ANNEXES/Pasted%20image%2020250513200105.png)

An outbound rule must be configured to enable internet connectivity for internal resources within the security group. This rule allows instances to download packages, updates, and communicate with external services necessary for the deployment pipeline.

![Outbound Rules Configuration](ANNEXES/Pasted%20image%2020250513195141.png)

Upon successful configuration, the security group is created and ready to be applied to EC2 instances throughout the laboratory.

![Security Group Created Successfully](ANNEXES/Pasted%20image%2020250513200125.png)

### Phase 2: Kubernetes Cluster Infrastructure

#### 2.1 Master Node Instance Creation

A dedicated EC2 instance is provisioned to serve as the control plane for the Kubernetes cluster deployment. This instance will execute Terraform scripts to provision the Amazon EKS cluster and associated resources.

![EC2 Instance Configuration](ANNEXES/Pasted%20image%2020250513200733.png)

During instance creation, a key pair must be generated to enable secure SSH access to the newly created instance. This key pair provides the cryptographic foundation for administrative access to the server.

![Key Pair Generation](ANNEXES/Pasted%20image%2020250513200526.png)

#### 2.2 SSH Connection Setup

To establish a secure connection to the provisioned instance, the following SSH configuration steps are executed:

```
ID de la instancia

[i-09b8ecd61dbd75627](https://us-east-2.console.aws.amazon.com/ec2/home?region=us-east-2#InstanceDetails:instanceId=i-09b8ecd61dbd75627) (goldencat-monitoring)

2. Abra un cliente SSH.

3. Localice el archivo de clave privada. La clave utilizada para lanzar esta instancia es BG.pem

4. Ejecute este comando, si es necesario, para garantizar que la clave no se pueda ver públicamente.

chmod 400 "BG.pem"

- Conéctese a la instancia mediante su DNS público:

ec2-3-137-185-149.us-east-2.compute.amazonaws.com

Ejemplo:

ssh -i "BG.pem" ubuntu@ec2-3-137-185-149.us-east-2.compute.amazonaws.com
```

#### 2.3 Environment Preparation and Tool Installation

Once connected to the instance, the system requires several essential tools for cluster provisioning and management. The following commands update the system and install necessary dependencies:

```
sudo apt update && sudo apt upgrade -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install
aws configure
```

#### 2.4 AWS CLI Configuration

AWS CLI configuration requires access credentials obtained through the creation of an access key in the AWS console. This step establishes programmatic access to AWS services required for infrastructure provisioning.

![AWS Access Key Creation](ANNEXES/Pasted%20image%2020250513202105.png)

After creating the access key, the AWS CLI configuration prompts are completed with the appropriate credentials, region, and output format settings.

#### 2.5 Terraform Infrastructure Deployment

Terraform is installed to manage infrastructure as code, providing reproducible and version-controlled infrastructure deployment:

```
sudo snap install terraform --classic
git clone https://github.com/EstebanGZam/Blue-Green-Deployment.git
cd Blue-Green-Deployment/Cluster/
terraform init
terraform plan
terraform apply -auto-approve
```

![Terraform Execution](ANNEXES/Pasted%20image%2020250513234458.png)

Upon successful Terraform execution, the EKS cluster and associated worker nodes are provisioned automatically, creating the foundational Kubernetes infrastructure.

![EKS Cluster Instances](ANNEXES/Pasted%20image%2020250513234602.png)

### Phase 3: DevOps Tool Server Provisioning

#### 3.1 Additional EC2 Instances

Three additional EC2 instances are provisioned to host the DevOps toolchain components. Each instance is configured with t2.medium specifications, the previously created security group, key pair, and 25GB of storage to ensure adequate resources for the respective services.

![Additional EC2 Configuration](ANNEXES/Pasted%20image%2020250513233441.png)

### Phase 4: Jenkins CI/CD Server Setup

#### 4.1 Jenkins Installation and Configuration

The Jenkins server is configured on the designated EC2 instance with Java Runtime Environment and the Jenkins automation server:

```
VM JENKINS
--------------------------------------------------
sudo apt update && sudo apt upgrade -y
sudo apt install openjdk-17-jre-headless -y
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
```

![Jenkins Installation Complete](ANNEXES/Pasted%20image%2020250514000547.png)

#### 4.2 Docker Integration

Docker is installed and configured on the Jenkins server to enable containerized build processes and deployment capabilities:

```
JENKINS 2
----------------------------------------------
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker jenkins
```

#### 4.3 Jenkins Initial Setup

Jenkins initial configuration is accessed through the web interface at the server's IP address on port 8080. The system requires a restart to complete the Docker integration.

![Jenkins Restart](ANNEXES/Pasted%20image%2020250514002435.png)

The initial administrator password is retrieved from the Jenkins secrets directory for first-time setup authentication.

![Jenkins Initial Setup](ANNEXES/Pasted%20image%2020250514003134.png)

### Phase 5: Nexus Repository Manager Setup

#### 5.1 Nexus Installation via Docker

Nexus Repository Manager is deployed using Docker containerization to provide artifact management capabilities:

```
NEXUS
-----------------------------------------------
sudo apt update && apt upgrade -y
sudo apt install docker.io -y
sudo usermod -aG docker $USER
newgrp docker
docker run -d --name nexus3 -p 8081:8081 sonatype/nexus3
docker exec -it nexus3 cat /nexus-data/admin.password
```

![Nexus Installation](ANNEXES/Pasted%20image%2020250513235530.png)

The initial administrator password is retrieved from the container for first-time authentication:

```
ubuntu@ip-172-31-12-142:~$ docker exec -it nexus3 cat /nexus-data/admin.password
15fee48c-ac5a-4a0c-a4e2-b85324925e91
```

![Nexus Login](ANNEXES/Pasted%20image%2020250514001059.png)

After successful authentication and password modification, the Nexus Repository Manager interface becomes accessible for artifact management configuration.

![Nexus Dashboard](ANNEXES/Pasted%20image%2020250514001210.png)

### Phase 6: SonarQube Code Quality Analysis Setup

#### 6.1 SonarQube Installation

SonarQube is deployed using Docker to provide comprehensive code quality analysis and security vulnerability detection:

```
SONAR
-------------------------------------------------
sudo apt update
sudo apt install docker.io -y
sudo usermod -aG docker ubuntu
newgrp docker
docker run -d -p 9000:9000 sonarqube:lts-community
```

![SonarQube Installation](ANNEXES/Pasted%20image%2020250514000633.png)

SonarQube is accessed through the web interface using default credentials (admin/admin) for initial configuration.

![SonarQube Login](ANNEXES/Pasted%20image%2020250514001546.png)

After authentication and password modification, the SonarQube dashboard becomes available for project analysis configuration.

![SonarQube Dashboard](ANNEXES/Pasted%20image%2020250514001745.png)

### Phase 7: Security Scanning Integration

#### 7.1 Trivy Installation

Trivy, a comprehensive vulnerability scanner, is installed on the Jenkins server to provide container image security analysis:

```
sudo apt-get install wget apt-transport-https gnupg lsb-release

wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list

sudo apt-get update
sudo apt-get install trivy
```

### Phase 8: Kubernetes Integration

#### 8.1 kubectl Installation and Configuration

Kubernetes command-line tool (kubectl) is installed on the Jenkins server to enable cluster management and deployment operations:

![kubectl Installation](ANNEXES/Pasted%20image%2020250514003627.png)

The kubeconfig is updated to establish connectivity with the provisioned EKS cluster:

```
sudo snap install kubectl --classic -y

aws eks --region us-east-2 update-kubeconfig --name devopsshack-cluster
```

![kubectl Configuration](ANNEXES/Pasted%20image%2020250514003935.png)

#### 8.2 RBAC Configuration

Role-Based Access Control (RBAC) is implemented to provide appropriate permissions for Jenkins to perform deployment operations within the Kubernetes cluster. This security model ensures that the CI/CD pipeline has the necessary privileges while maintaining security boundaries:

```
kubectl create ns webapps

kubectl apply -f sa.yml

kubectl apply -f role.yml

kubectl apply -f rolebind.yml

kubectl apply -f sec.yaml -n webapps

kubectl describe secret mysecretname -n webapps
```

![RBAC Configuration](ANNEXES/Pasted%20image%2020250514005655.png)

![Service Account Token](ANNEXES/Pasted%20image%2020250514010042.png)

The service account token is retrieved for Jenkins authentication with the Kubernetes cluster:

```
ubuntu@ip-172-31-0-157:~/Blue-Green-Deployment/Cluster$ kubectl describe secret mysecretname -n webapps
Name:         mysecretname
Namespace:    webapps
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: jenkins
              kubernetes.io/service-account.uid: 12eb3286-7c83-4a5c-8a1f-5f3a602ed9af

Type:  kubernetes.io/service-account-token

Data
====
namespace:  7 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IjZXUGxkaDRidEEtMzI2NGxVMEpYaUxBd2hiSGdnamZsNjR6djV6M3diTU0ifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJ3ZWJhcHBzIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im15c2VjcmV0bmFtZSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJqZW5raW5zIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiMTJlYjMyODYtN2M4My00YTVjLThhMWYtNWYzYTYwMmVkOWFmIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OndlYmFwcHM6amVua2lucyJ9.11S8qfItv5srHQhBpmUFa2a2ePO5Qn9qVmkYH7fZMlkfMdcLPM4Cm0NAKvOwNdbTKuY25GcQTbC0ecTaZWwVwz6eH_p7vzFrZjoQ5qYm6MwIRQX3tC6-jN-NE7MrXzO_ThN2xdlulBxljo8jqUQLitpQXX5JAUPjxp9MvzZAfpgj6yRkBkCF6DEknKcjhDwOVwqmOxTmzFe9510VmQm4hCPPQsqgo4SrqEqFiL83JOfyFXk8rl7ItkKNE3zdLrwdkL20llobH8OjfGzPGzo7ZibJaR6rZQuA3vJHdSzvH_G1DxNI25Qj9VclrQh8Dq1uQjJIEUd0IimwRyV_2tv1xg
ca.crt:     1107 bytes
```

### Phase 9: Jenkins Pipeline Configuration

#### 9.1 Kubernetes Credentials Setup

The Kubernetes service account token is configured as a secret text credential in Jenkins to enable authenticated communication with the EKS cluster:

- **Type**: Secret text
- **Scope**: Global
- **Secret**: Kubernetes service account token
- **ID**: k8-token
- **Description**: Token for Kubernetes cluster access

![Jenkins Kubernetes Credentials](ANNEXES/Pasted%20image%2020250514011006.png)

#### 9.2 Essential Plugin Installation

The following plugins are installed in Jenkins to enable comprehensive CI/CD pipeline functionality:

- SonarQube Scanner
- Maven Integration
- Config File Provider
- Pipeline Maven Integration
- Docker Pipeline
- Pipeline Stage View
- Generic Webhook Trigger
- Kubernetes
- Kubernetes CLI
- Kubernetes Credentials
- Kubernetes Client API

![Jenkins Plugins Installation](ANNEXES/Pasted%20image%2020250514082741.png)

#### 9.3 Maven Configuration

Maven is configured within Jenkins Global Tool Configuration to enable Java project builds and dependency management.

![Maven Configuration](ANNEXES/Pasted%20image%2020250514083846.png)

#### 9.4 SonarQube Integration

A SonarQube authentication token is generated to enable Jenkins integration with the code quality analysis platform.

![SonarQube Token Generation](ANNEXES/Pasted%20image%2020250514085556.png)

The generated token is configured as a secret text credential in Jenkins for secure SonarQube communication.

![SonarQube Jenkins Integration](ANNEXES/Pasted%20image%2020250514085744.png)

#### 9.5 Nexus Repository Integration

Maven settings are configured to integrate with the Nexus Repository Manager for artifact storage and retrieval. The project's pom.xml file is updated with the appropriate Nexus repository URLs:

```
	<distributionManagement>
        <repository>
            <id>maven-releases</id>
            <url>http://3.21.100.237:8081/repository/maven-releases/</url>
        </repository>
        <snapshotRepository>
            <id>maven-snapshots</id>
            <url>http://3.21.100.237:8081/repository/maven-snapshots/</url>
        </snapshotRepository>
    </distributionManagement>
```

## Technical Implementation Benefits

### Blue-Green Deployment Advantages

The implemented Blue-Green deployment strategy provides several critical benefits:

1. **Zero-Downtime Deployments**: Traffic is seamlessly switched between environments without service interruption
2. **Risk Mitigation**: Immediate rollback capability if issues are detected in the new version
3. **Production Testing**: The new version can be thoroughly tested in a production-like environment before traffic switching
4. **Performance Validation**: Load and performance testing can be conducted on the green environment before deployment

### DevOps Pipeline Integration

The comprehensive toolchain provides:

1. **Automated Quality Gates**: SonarQube integration ensures code quality standards are maintained
2. **Security Scanning**: Trivy provides vulnerability assessment for container images
3. **Artifact Management**: Nexus Repository centralizes dependency and build artifact storage
4. **Infrastructure as Code**: Terraform ensures reproducible and version-controlled infrastructure
5. **Container Orchestration**: Kubernetes provides scalable and resilient application deployment

## Conclusion

This laboratory successfully demonstrates the implementation of a production-ready Blue-Green deployment strategy using modern DevOps practices and cloud-native technologies. The established infrastructure provides a foundation for reliable, secure, and automated application deployments with minimal risk and downtime. The integration of comprehensive quality gates, security scanning, and automated testing ensures that only validated code reaches production environments while maintaining the ability to quickly rollback if issues arise.

The implemented solution showcases industry best practices for continuous integration and deployment, providing a robust framework for enterprise-level application delivery pipelines.
