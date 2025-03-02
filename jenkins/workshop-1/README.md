## **Part One: Jenkins Controller Installation and Configuration in Docker**

### Creating a Bridge Network in Docker

To facilitate communication between the Jenkins controller and its agents, a dedicated Docker network is created. This ensures that all related containers operate within an isolated network, preventing conflicts with other containers and enabling seamless connectivity.

```
docker network create jenkins
```

![Image](ANNEXES/Pasted%20image%2020250228115539.png)

### Running a Docker-in-Docker (DinD) Container

To allow Jenkins to build and manage Dockerized applications, a `docker:dind` (Docker-in-Docker) container is launched. This provides a dedicated Docker daemon within the network, enabling Jenkins agents to execute Docker commands without requiring direct installation of Docker on the host machine.

```
docker run \
  --name jenkins-docker \
  --rm \
  --detach \
  --privileged \
  --network jenkins \
  --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind \
  --storage-driver overlay2
```

![Image](ANNEXES/Pasted%20image%2020250228115552.png)

### Building a Custom Jenkins Image

A custom Jenkins image is created to include the necessary Docker CLI tools and required plugins. This ensures Jenkins can interact with Docker effectively. The following Dockerfile installs `docker-ce-cli` and the essential plugins, such as Blue Ocean and Docker Workflow.

```
FROM jenkins/jenkins:2.492.1-jdk17

USER root

RUN apt-get update && apt-get install -y lsb-release

RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg

RUN echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
https://download.docker.com/linux/debian \
$(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

RUN apt-get update && apt-get install -y docker-ce-cli

USER jenkins

RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
```

The image is then built using the following command:

```
docker build -t myjenkins-blueocean:2.492.1-1 .
```

![Image](ANNEXES/Pasted%20image%2020250228121640.png)

### Running the Jenkins Controller

The Jenkins controller is deployed using the previously built custom image. This container is configured to interact with the DinD instance via environment variables, ensuring Jenkins can utilize Docker capabilities securely.

```
docker run \
  --name jenkins-blueocean \
  --restart=on-failure \
  --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 \
  --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  myjenkins-blueocean:2.492.1-1
```

![Image](ANNEXES/Pasted%20image%2020250228123946.png)

Once the container is running, Jenkins is accessible at `http://localhost:8080`, where the initial setup and plugin installation process can be completed.

---

### Unlocking Jenkins

To unlock Jenkins, navigate to `http://localhost:8080` in a web browser.

![Image](ANNEXES/Pasted%20image%2020250228124009.png)

The initial administrator password is required and can be retrieved from the container logs using the following command:

```bash
docker logs <docker-container-name>
```

![Image](ANNEXES/Pasted%20image%2020250228124143.png)

After pasting the password, install the suggested plugins to ensure Jenkins functions correctly:

![Image](ANNEXES/Pasted%20image%2020250228124154.png)

Once the installation is complete, create the first administrator user:

![Image](ANNEXES/Pasted%20image%2020250228124442.png)

Jenkins is now fully set up and accessible with the newly created credentials:

![Image](ANNEXES/Pasted%20image%2020250228124511.png)

---

### Resolving Plugin Errors

If errors appear in the **Manage Jenkins** section related to plugins, the affected plugins should be reinstalled manually. This can be done by accessing the Jenkins container and removing the faulty plugins:

```bash
docker exec -it jenkins-blueocean /bin/bash
```

```bash
cd /var/jenkins_home/plugins
rm -f token-macro.hpi github.hpi blueocean.hpi
exit
```

After removing the problematic plugins, restart the Jenkins container to apply the changes:

```bash
docker restart jenkins-blueocean
```

Jenkins should now function correctly without plugin-related errors.

---
## **Part Two: Integrating Agents with the Jenkins Controller**
### Generating an SSH Credential for Jenkins

To enable secure authentication between Jenkins and its agents, an SSH key pair must be generated. This key pair allows the Jenkins controller to authenticate with the agent securely.

#### Step 1: Generate an SSH Key for Jenkins

Execute the following command to create a new SSH key pair:

```bash
ssh-keygen -f ~/.ssh/jenkins_agent_key
```

![Image](ANNEXES/Pasted%20image%2020250228124633.png)

This command generates a private key (`jenkins_agent_key`) and a public key (`jenkins_agent_key.pub`) inside the `~/.ssh/` directory.

#### Step 2: Register the SSH Key in Jenkins

To register the generated SSH key in Jenkins, navigate to **Manage Jenkins > Credentials** and select the `Add Credentials` option.

![Image](ANNEXES/Pasted%20image%2020250301174710.png)

Once inside, complete the credential form as follows:

- **Kind**: SSH Username with private key
- **ID**: jenkins
- **Description**: The Jenkins SSH key
- **Username**: jenkins
- **Private Key**: Select `Enter directly` and paste the content of the private key file (`~/.ssh/jenkins_agent_key`)
- **Passphrase**: Enter the passphrase if one was used when generating the SSH key (leave empty if none was used), then press `Create`

![Image](ANNEXES/Pasted%20image%2020250301175353.png)

To retrieve the private key content, use the following command:

```bash
cat ~/.ssh/jenkins_agent_key
```

![Image](ANNEXES/Pasted%20image%2020250301175434.png)

Once the credential is registered, the SSH key setup is complete.

![Image](ANNEXES/Pasted%20image%2020250301175504.png)

---

### Creating the Docker Agent

To create an SSH-based Jenkins agent, run the following command:

```bash
docker run -d --rm --name=agent1 -p 22:22 \
-e "JENKINS_AGENT_SSH_PUBKEY=[your-public-key]" \
jenkins/ssh-agent:alpine-jdk17
```

The `[your-public-key]` placeholder must be replaced with the actual content of the public key, which can be retrieved using:

```bash
cat ~/.ssh/jenkins_agent_key.pub
```

![Image](ANNEXES/Pasted%20image%2020250301180728.png)

After executing the command, the `agent1` container will be running.

![Image](ANNEXES/Pasted%20image%2020250301180805.png)

---

### Configuring the Agent in Jenkins

To add the agent to Jenkins, navigate to **Manage Jenkins > Nodes** and create a new node.

![Image](ANNEXES/Pasted%20image%2020250301180021.png)

Fill in the form according to Jenkins' recommended configuration.

![Image](ANNEXES/Pasted%20image%2020250301181427.png)

Once created, the agent will appear in the node panel.

![Image](ANNEXES/Pasted%20image%2020250301181747.png)

Select the node and click `Relaunch Agent`. If the following error appears:

![Image](ANNEXES/Pasted%20image%2020250301181703.png)

It indicates that the private SSH key is missing in the Jenkins controller. The agent must recognize the public key, and the controller must have the private key.

### How to solve this error?
#### Step 1: Ensure Network Connectivity

Connect the agent container to the same network as the Jenkins controller:

```bash
docker network connect jenkins agent1
```

#### Step 2: Configure SSH Keys on the Jenkins Controller

1. **Create the `.ssh` directory in the Jenkins controller**
    
    This ensures that Jenkins has a secure location to store SSH keys:
    
    ```bash
    docker exec -it jenkins-blueocean sh -c "mkdir -p /var/jenkins_home/.ssh && chmod 700 /var/jenkins_home/.ssh"
    ```
    
2. **Copy the SSH keys to the Jenkins controller**
    
    The private and public keys must be available inside the controller:
    
    ```bash
    docker cp ~/.ssh/jenkins_agent_key jenkins-blueocean:/var/jenkins_home/.ssh/jenkins_agent_key
    docker cp ~/.ssh/jenkins_agent_key.pub jenkins-blueocean:/var/jenkins_home/.ssh/jenkins_agent_key.pub
    ```
    
    ![Image](ANNEXES/Pasted%20image%2020250301184729.png)
    
3. **Ensure proper file permissions**
    
    The following commands adjust ownership and permissions to ensure Jenkins can use the keys securely:
    
    ```bash
    docker exec -it jenkins-blueocean sh -c "chmod 600 /var/jenkins_home/.ssh/jenkins_agent_key"
    docker exec -it jenkins-blueocean sh -c "chmod 644 /var/jenkins_home/.ssh/jenkins_agent_key.pub"
    docker exec -it jenkins-blueocean sh -c "chown -R jenkins:jenkins /var/jenkins_home/.ssh"
    ```
    
    ![Image](ANNEXES/Pasted%20image%2020250301184753.png)
    
4. **Verify the SSH keys inside the container**
    
    ```bash
    docker exec -it jenkins-blueocean sh -c "ls -l /var/jenkins_home/.ssh"
    ```
    
    ![Image](ANNEXES/Pasted%20image%2020250301185340.png)
    
    If the keys are listed correctly, the setup is complete.
    

#### Step 3: Verify SSH Connection

To confirm the connection between the controller and the agent, manually establish an SSH session:

```bash
docker exec -it jenkins-blueocean sh -c "ssh -i /var/jenkins_home/.ssh/jenkins_agent_key jenkins@agent1"
```

![Image](ANNEXES/Pasted%20image%2020250301185503.png)

If the connection succeeds, the Jenkins agent is correctly configured.

#### Step 4: Relaunch the Agent in Jenkins

Finally, navigate to the agent's configuration page in Jenkins and click `Relaunch Agent`. If the setup is correct, the agent should connect successfully.

![Image](ANNEXES/Pasted%20image%2020250301184134.png)

---

## **Part Three: Jenkins Pipeline Implementation with GitHub and Maven**

### 1. Creating a Pipeline Item in Jenkins

To begin, a new **Pipeline** item must be created in Jenkins. This serves as the container for the pipeline script that automates build, test, and deployment processes.

![Image](ANNEXES/Pasted%20image%2020250301192406.png)

During the creation, the pipeline type is selected, and a suitable name is assigned.

![Image](ANNEXES/Pasted%20image%2020250301204337.png)

The following Jenkins pipeline script is used:

```bash
pipeline {
    agent {
        docker {
            image 'maven:3.9.2'
            args '-u root'
        }
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/EstebanGZam/simple-java-maven-app.git'
            }
        }
        stage('Build') {
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }
    }
}
```

#### Explanation of the Pipeline

- **Agent:** Uses the `maven:3.9.2` Docker image to execute the pipeline. This version was chosen for stability.
- **Stages:**
    - **Checkout:** Clones the repository from GitHub using the `master` branch.
    - **Build:** Runs the Maven command to compile the application without executing tests.

![Image](ANNEXES/Pasted%20image%2020250301204228.png)

### 2. Extending the Pipeline to Include Testing and Deployment

The pipeline is now modified to include testing and deployment.

```bash
pipeline {
    agent {
        docker {
            image 'maven:3.9.2'
            args '-u root'
        }
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/EstebanGZam/simple-java-maven-app.git'
            }
        }
        stage('Build') {
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('Deliver') {
            steps {
                sh './jenkins/scripts/deliver.sh'
            }
        }
    }
}
```

#### Modifications and Enhancements

1. **Test Stage:**
    
    - Executes `mvn test` to run unit tests.
    - Collects test reports via `junit 'target/surefire-reports/*.xml'`.
2. **Deliver Stage:**
    
    - Executes `./jenkins/scripts/deliver.sh`, which can include deployment steps such as copying artifacts or triggering a deployment service.

![Image](ANNEXES/Pasted%20image%2020250301205552.png)

### 3. Ensuring a Clean Workspace

A new **Prepare Workspace** stage is introduced to remove any existing project directory before cloning the repository.

```groovy
pipeline {
    agent {
        docker {
            image 'maven:3.9.2'
            args '-u root'
        }
    }
    stages {
        stage('Prepare Workspace') {
            steps {
                script {
                    if (fileExists('simple-java-maven-app')) {
                        echo "Removing existing directory..."
                        sh 'rm -rf simple-java-maven-app'
                    }
                }
            }
        }
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/EstebanGZam/simple-java-maven-app.git'
            }
        }
        stage('Build') {
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('Deliver') {
            steps {
                sh './jenkins/scripts/deliver.sh'
            }
        }
    }
}
```

#### Why This Change?

- Ensures that outdated files or configurations do not interfere with the pipeline execution.
- Guarantees that the repository is always pulled fresh, reducing potential issues with uncommitted changes.

### 4. Adding a Branch Selection Parameter

To allow dynamic selection of branches, a **parameterized build** is implemented.

```groovy
parameters {
    string(name: 'BRANCH_NAME', defaultValue: 'master', description: 'Specify the branch to compile (e.g., master, declarative, testng)')
}
stages {
    stage('Checkout') {
        steps {
            script {
                echo "Cloning selected branch: ${params.BRANCH_NAME}"
            }
            git branch: "${params.BRANCH_NAME}", url: 'https://github.com/EstebanGZam/simple-java-maven-app.git'
        }
    }
}
```

#### Key Enhancements

- Allows Jenkins users to specify the branch to build.
- Prevents unnecessary modifications to the pipeline script.

![Image](ANNEXES/Pasted%20image%2020250301214027.png)

![Image](ANNEXES/Pasted%20image%2020250301214401.png)

![Image](ANNEXES/Pasted%20image%2020250301214742.png)

A validation mechanism ensures that the selected branch exists; otherwise, Jenkins will return an error:

```
ERROR: Couldn't find any revision to build. Verify the repository and branch configuration for this job.
```

In this case, the branch does exist, so no error is obtained

![Image](ANNEXES/Pasted%20image%2020250301214706.png)

### 5. Moving the Script to an External File

To enhance maintainability, the script is extracted into an external file and referenced in the Jenkins pipeline. You can see the created Jenkins file by clicking [here](https://github.com/EstebanGZam/simple-java-maven-app/blob/master/Jenkinsfile).

![Image](ANNEXES/Pasted%20image%2020250301215635.png)

This final adjustment ensures better code management and modularity.

![Image](ANNEXES/Pasted%20image%2020250301224831.png)
