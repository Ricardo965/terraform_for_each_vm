# Terraform Project - Infrastructure with VMs and GitHub Webhook

This is a project where I'm using Terraform to provision cloud infrastructure in an automated way. The main goal is to provision multiple virtual machines using a `for_each`, and set up a GitHub webhook pointing to the public IP of a VM that acts as a Jenkins server.

## 🏗️ Project Structure

```bash
.
├── main.tf                     # Main file where I orchestrate the modules
├── modules                     # Contains reusable modules
│   ├── gh                      # Module to manage the GitHub webhook
│   │   ├── main.tf
│   │   └── variables.tf
│   └── vm                      # Module to create virtual machines
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── outputs.tf                  # Definition of global outputs
├── providers.tf                # Terraform provider configuration
├── README.md                   # This file :)
├── secrets.tfvars              # Sensitive variables (not uploaded to the repo)
├── terraform.sh                # Script to automate Terraform commands
└── variables.tf                # Global variables
```

## 🚀 What Does This Project Do?

1. **VM Provisioning**  
   I use a module (`modules/vm`) to spin up multiple virtual machines. I use a `for_each` to iterate over a list/map of configurations to avoid repeating code.

2. **Jenkins Server**  
   Among the VMs I create, one is labeled as `jenkins`. This one is assigned a public IP since it needs to be accessible from GitHub.

3. **GitHub Webhook**  
   Using another module (`modules/gh`), I create a webhook in a GitHub repository. This webhook points to the public IP of the `jenkins` VM, which allows me to automate CI/CD tasks from GitHub to Jenkins.

## ⚙️ How to Use It

### 1. Configure Your Variables

In the `secrets.tfvars` file, you should define your private credentials and configurations, such as GitHub tokens, SSH keys, etc.

Since the project runs on my machine where I'm logged into GitHub, it uses those credentials by default to create the webhook. If the machine running the project is not logged into GitHub, it's recommended to include the PAT token in the variables.

```hcl
subscription_id = "sub_id_az"

# Additional configurations
prefix_name = "project-tsaj"
region      = "eastus"

# VM credential configurations
user     = "adminuser"
password = "SecretPassword1234!"
# servers  = ["jenkins"]
servers = ["jenkins", "nginx"]
```

### 2. Run Terraform

The entire deployment is automated in the `terraform.sh` script.

```bash
chmod +x terraform.sh
```

```bash
./terraform.sh
```

Or manually:

```bash
terraform init
terraform fmt
terraform validate
terraform plan -var-file="secrets.tfvars"
terraform apply -var-file="secrets.tfvars -auto-approve"
```

### 3. Deployment

Once deployed, you'll have VMs for Jenkins and Nginx.  
The script automates the deployment and creates a `.txt` file called `ips.txt`. This file is used to store the VMs' IPs in the following format:

```bash
jenkins: dir_ip
nginx: dir_ip
```

The script creates this file at the same level as the parent folder of this project:

```
.
├── terraform_for_each_vm/
├── ips.txt
```

This is designed to be used alongside the [ansible-pipeline](https://github.com/Ricardo965/ansible-pipeline) project, which includes the remaining scripts to manage and provision the infrastructure with Nginx and configure Sonar and Jenkins on the respective VM.

The recommended project structure for proper deployment is as follows:

```
.
├── ansible-pipeline
├── deploy.sh
├── ips.txt
├── KeyboardDeploy
├── terraform_for_each_vm
└── update_hosts.sh
```

### 4. Suggestions for Improvement

- **Resource Modularization:** Split the infrastructure into reusable modules to improve code organization, make maintenance easier, and allow reuse in other projects. The VM module currently contains a lot of logic that could be abstracted into a networking module.

- **Validation and Testing:** Implement validation (`tflint`) and automated tests (`terratest`) to ensure code quality and consistency before applying changes.

- **Remote State Management:** Configure a remote backend (like S3 + DynamoDB on AWS) to share and lock state between teams, enabling collaborative work and concurrency control.
