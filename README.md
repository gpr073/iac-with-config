# iac-with-config

## Description

Used Terraform and Ansible to provision and configure an EC2 server which then runs the TodoList container by pulling it from ECR public repository.
- Terraform provisions the necessary resources.
- Terraform also executes the Ansible playbook after provisioning using a null resource.
- Ansible is used to configure the created EC2 server by using the IP provided by terraform output.
- Ansible playbook installs the packages needed and adds user to necessary groups.
- The playbook then copies over the docker-compose.yaml file to the EC2 server where it gets executed.

## Getting Started

### Dependencies

* AWS
* Terraform
* Ansible

### Executing program

* Install AWS CLI, Terraform, Ansible.
* Configure AWS Credentials using AWS CLI.
* Create an EC2 keypair and provide the name to main.tf file.
* Run the Terraform file.
* The web application starts on port 3000.
```
terraform init
terraform apply
```
