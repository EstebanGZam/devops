**Estudiante:** Esteban Gaviria Zambrano - A00396019
# Preparing the environment: Docker 24 Installation on a VM with Multipass

## 1. Environment Description

- **Host Operating System:** Linux Mint 22.1
- **Reason:** Docker 24 or an earlier version is required due to the need to modify the storage driver, which is not supported in later versions.
- **Solution:** A virtual machine (VM) with Ubuntu 20.04 LTS will be used via [Multipass](https://canonical.com/multipass) to keep the Docker version isolated without affecting the host system.

## 2. Preparing the Environment

### 2.1. Installing Multipass

1. **Update system packages:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
2. **Install Multipass:**
   ```bash
   sudo snap install multipass
   ```
3. **Verify the installation:**
   ```bash
   multipass version
   ```

> **Note:** If `snap` is not installed, it must be installed first using the following commands:

```bash
sudo apt install snapd -y
sudo systemctl enable --now snapd
```

## 3. Creating a VM with Ubuntu 20.04

1. **Create a VM with Ubuntu 20.04 and the necessary resources:**
   ```bash
   multipass launch --name docker-24 --memory 2G --disk 5G --cpus 1 20.04
   ```
2. **Access the VM:**
   ```bash
   multipass shell docker-24
   ```

## 4. Installing Docker 24 on the VM

### 4.1. Initial Configuration

1. **Update packages inside the VM:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
2. **Install necessary dependencies:**
   ```bash
   sudo apt install -y ca-certificates curl gnupg lsb-release
   ```

### 4.2. Adding the Docker Repository

1. **Add Docker's official GPG key:**
   ```bash
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   ```
2. **Add the Docker repository for Ubuntu 20.04:**
   ```bash
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu focal stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```
3. **Update the package list:**
   ```bash
   sudo apt update
   ```

### 4.3. Installing Docker

1. **Check available Docker versions:**
   ```bash
   apt-cache madison docker-ce
   ```
2. **Install Docker CE version 24.0.9:**
   ```bash
   sudo apt install -y docker-ce=5:24.0.9-1~ubuntu.20.04~focal docker-ce-cli=5:24.0.9-1~ubuntu.20.04~focal containerd.io
   ```
3. **Verify the Docker installation:**
   ```bash
   docker --version
   ```

### 4.4. Additional Configuration

1. **Enable and start the Docker service:**
   ```bash
   sudo systemctl enable --now docker
   sudo systemctl status docker
   ```
![Image](./ANNEXES/Pasted%20image%2020250226220514.png)

1. **Allow running Docker without `sudo`:**
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

With these steps completed, Docker 24 is correctly installed and configured on the VM, ready for use.

# Workshop Steps Execution

## 1. Run a Hello World Container
To do this, use the following command:
```
docker run hello-world
```
![Image](./ANNEXES/Pasted%20image%2020250226222747.png)

## 2. Modifying the Storage Driver

1. **Check the current storage driver:**
   ```bash
   docker info | grep "Storage Driver"
   ```
   - Output:
   - ![Image](./ANNEXES/Pasted%20image%2020250226224252.png)

2. **Modify the storage driver to `devicemapper` in the configuration file:**
   ```bash
   sudo nano /etc/docker/daemon.json
   ```
   - Configuration:
     ```json
     {
       "storage-driver": "devicemapper"
     }
     ```
3. **Restart the Docker service:**
   ```bash
   sudo systemctl restart docker
   ```
4. **Verify the change:**
   ```bash
   docker info | grep "Storage Driver"
   ```
   - Output:
   - ![Image](./ANNEXES/Pasted%20image%2020250226224315.png)

5. **Run a test container:**
   ```bash
   docker run hello-world
   ```
   ![Image](./ANNEXES/Pasted%20image%2020250226224438.png)

6. **Revert the storage driver back to `overlay2`:**
   ```bash
   sudo nano /etc/docker/daemon.json
   ```
   - Configuration:
     ```json
     {
       "storage-driver": "overlay2"
     }
     ```
7. **Restart Docker and verify:**
   ```bash
   sudo systemctl restart docker
   docker info | grep "Storage Driver"
   ```
   ![Image](./ANNEXES/Pasted%20image%2020250226224508.png)

## 3. Running and Configuring Nginx

1. **Run Nginx version 1.18.0:**
   ```bash
   docker run --rm nginx:1.18.0
   ```
   ![Image](./ANNEXES/Pasted%20image%2020250226224610.png)

2. **Run Nginx in detached mode:**
   ```bash
   docker run -d nginx:1.18.0
   ```
3. **Verify running containers:**
   ```bash
   docker ps
   ```
   ![Image](./ANNEXES/Pasted%20image%2020250226224656.png)

4. **Configure Nginx with specific settings:**
   ```bash
   docker run -d \
     --name nginx18 \
     --restart on-failure \
     -p 443:80 \
     --memory=250m \
     nginx:1.18.0
   ```
5. **Verify that the container is running with the correct configuration:**
   ```bash
   docker ps
   ```
   ![Image](./ANNEXES/Pasted%20image%2020250226224725.png)

## 3. Changing the Logging Driver

1. **Check the current logging driver:**
   ```bash
   docker info | grep "Logging Driver"
   ```
   - Output:
   - ![Image](./ANNEXES/Pasted%20image%2020250226224742.png)

2. **Modify the logging driver to `journald` in the configuration file:**
   ```bash
   sudo nano /etc/docker/daemon.json
   ```
   - Configuration:
     ```json
     {
       "log-driver": "journald"
     }
     ```
3. **Restart Docker and verify:**
   ```bash
   sudo systemctl restart docker
   docker info | grep "Logging Driver"
   ```
   - Output:
   - ![Image](./ANNEXES/Pasted%20image%2020250226224806.png)

4. **Retrieve the logs after changing the logging driver:**
    ```
    journalctl -u docker --no-pager | tail -n 50
    ```
   ![Image](./ANNEXES/Pasted%20image%2020250226225857.png)

With these steps completed, the workshop tasks were successfully executed, and Docker is configured according to the specified requirements.
