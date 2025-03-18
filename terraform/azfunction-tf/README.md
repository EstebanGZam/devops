### **Infrastructure as Code**

- **Use definition files**: All infrastructure-as-code tools have their own format for defining infrastructure.
- **Self-documenting processes and systems**: By using the infrastructure-as-code approach, we can reuse code. It is important to document it properly so that other users understand the purpose and functionality of the module.
- **Version everything**: This allows us to track changes made. If a mistake is made, we can revert to a stable version.
- **Prefer small changes**: Make small changes to avoid large impacts.
- **Keep services continuously available**: Ensuring continuous availability is key in infrastructure.

### **Benefits of Infrastructure as Code**

- **Fast and on-demand creation**: With a single infrastructure definition file that stores all our configurations, we can create infrastructure multiple times without needing to redo everything from scratch.
- **Automation**: Once the definition file is created, we can use **continuous integration** tools to automate infrastructure management.
- **Visibility and traceability**: Versioning infrastructure as code provides greater visibility and traceability, as all changes are recorded.
- **Homogeneous environments**: We can create multiple environments from the same definition file, changing only a few parameters.

---

### **Best Practices**

- **Modularity**: It is recommended to divide infrastructure into reusable modules to facilitate maintenance and scalability.
- **Centralized configurations**: Use variables and configuration files to manage parameters and avoid "hardcoded" values.
- **Secure state management**: Store the `terraform.tfstate` file remotely (e.g., in an S3 bucket with versioning) to avoid issues in distributed teams.
- **Code reviews and pull requests**: Before applying significant changes to the infrastructure, conduct reviews through pull requests to ensure changes have been reviewed by others.

### **Environments**

Terraform allows the creation of multiple environments (dev, stage, prod) with different configurations. You can manage these environments using specific `.tfvars` files for each environment.

- **Development environment (dev)**: It is recommended to use smaller and cheaper resources in this environment to reduce costs.
- **Production environment (prod)**: Here, it is important to configure instances and resources with redundancy and high availability.

Example structure for managing environments:

```bash
├── main.tf
├── variables.tf
├── dev.tfvars
├── prod.tfvars
```

When applying changes for a specific environment, you can run:

```bash
terraform apply --var-file="dev.tfvars"
```

### **Automation with CI/CD**

Integrating Terraform into a CI/CD pipeline is an excellent practice for automating infrastructure management. You can use tools like Jenkins, GitLab CI, or GitHub Actions to automate the deployment and validation process.

Example of a basic pipeline in GitLab CI:

```yaml
stages:
  - validate
  - plan
  - apply

validate:
  script:
    - terraform init
    - terraform validate

plan:
  script:
    - terraform plan

apply:
  script:
    - terraform apply --auto-approve
```

This pipeline first initializes the environment, then validates the configuration, and finally applies the changes automatically.

### **Security**

- **Secure credential management**: Never store credentials in the source code. Use tools like **AWS Secrets Manager** or **HashiCorp Vault** to manage secrets securely.
- **Role-based access control (IAM)**: Assign specific roles and permissions to Terraform resources using IAM policies to restrict access as needed.
- **Data encryption**: Use encryption at rest and in transit to protect sensitive data, such as using **KMS (Key Management Service)** from AWS.
- **State security**: If you store the `terraform.tfstate` file in an S3 bucket, ensure encryption and versioning are enabled to prevent unauthorized modifications.

---

### **Variable Management in Terraform**

To make the infrastructure definition file scalable and reusable, it is recommended to avoid "hardcoded" values. Terraform allows creating variables of the following types:

- **string**
- **number**
- **boolean**
- **map**
- **list**

If no type is declared, the default value will be `string`. However, it is good practice to specify the variable type.

Example of variable definition:

```terraform
variable "ami_id" {
  type        = string
  description = "AMI ID"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
}

variable "tags" {
  type        = map
  description = "Tags for the instance"
}
```

### **Assigning Values to Variables**

Variable values can be assigned in three ways:

1. Using environment variables.
2. Passing them as arguments in the command line.
3. Through a `.tfvars` file with `key = value` format.

Example of a `.tfvars` file:

```terraform
ami_id        = "ami-0ca0c67309196175e"
instance_type = "t2.micro"
tags = {
  Name       = "devops-tf"
  Environment = "Dev"
}
```

To use this file with variables:

```bash
terraform apply --var-file="dev.tfvars"
```

### **Destroying Infrastructure**

To delete the created infrastructure, you can use:

```bash
terraform destroy --var-file="dev.tfvars" -auto-approve
```
