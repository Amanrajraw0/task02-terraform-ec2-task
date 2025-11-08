# ☁️ Task 02 – Terraform EC2 Infrastructure Automation

[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform)](https://www.terraform.io/)
[![AWS EC2](https://img.shields.io/badge/Cloud-AWS%20EC2-orange?logo=amazon-aws)](https://aws.amazon.com/ec2/)
[![Docker](https://img.shields.io/badge/Container-Docker-blue?logo=docker)](https://www.docker.com/)
[![Region](https://img.shields.io/badge/Region-Europe%20(Stockholm)%20eu--north--1-blue)](https://aws.amazon.com/about-aws/global-infrastructure/)
[![Instance](https://img.shields.io/badge/Type-t3.micro-success)](https://aws.amazon.com/ec2/instance-types/)

---

## 🏢 Company Task – NulClass Internship
This project was completed as part of my **DevOps Internship Task 02** under **NulClass**.  
The objective was to automate **AWS EC2 infrastructure creation** using **Terraform**, install **Docker** automatically, and manage everything securely via **AWS CLI**.

---

## 📘 Project Overview
This Terraform project:
- Launches an **Ubuntu 22.04 EC2 Instance (Free Tier t3.micro)** in **eu-north-1**.  
- Opens **port 22 (SSH)** and **port 80 (HTTP)**.  
- Installs **Docker** automatically using a `user_data` script.  
- Uses **AWS CLI credentials** for secure authentication.  
- Demonstrates complete **Infrastructure as Code (IaC)** workflow.

---

## 🧰 Tools & Technologies Used

| Tool / Technology | Purpose |
|--------------------|----------|
| **Terraform** | Infrastructure automation (IaC) |
| **AWS EC2** | Cloud virtual machine |
| **AWS CLI v2** | Credential management |
| **Docker** | Container runtime |
| **Ubuntu 22.04 LTS** | Instance OS |
| **Git & GitHub** | Version control & project hosting |

---

## 📂 Final Repository Structure

```bash
terraform-ec2-task/
│
├── main.tf # Main Terraform configuration
├── provider.tf # AWS provider block
├── variables.tf # Input variables
├── outputs.tf # Public IP & Instance ID outputs
├── user_data.sh # Docker installation script
├── .gitignore # Ignore Terraform state files
└── README.md # Documentation
```

---

## ⚙️ Implementation Steps

### 1️⃣ Setup AWS CLI on EC2
```bash
sudo apt update -y
sudo apt install unzip curl -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```
### 2️⃣ Configure AWS Credentials (Secure Method)
```bash
aws configure
```
- Input:
```bash
AWS Access Key ID: <your-access-key>
AWS Secret Access Key: <your-secret-key>
Default Region: eu-north-1
Output Format: json
```
- ✅ Credentials are stored securely at ~/.aws/credentials

### 3️⃣ Create Terraform Files
- 🧾 provider.tf
```hcl
# provider.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}
```
- 🧾 variables.tf
```bash
# variables.tf
variable "aws_region" {
  description = "AWS region for the EC2 instance"
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing AWS Key Pair name"
  default     = "website_responsive"
}
```
- 🧾 user_data.sh
```bash
#!/bin/bash
sudo apt update -y
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
echo "Docker installed successfully!" > /home/ubuntu/docker_status.txt
```
- 🧾 main.tf
```bash
# main.tf

# Get latest Ubuntu 22.04 AMI dynamically
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical (official Ubuntu account)
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get the first subnet
data "aws_subnet" "selected" {
  id = element(data.aws_subnets.default.ids, 0)
}

# Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "web_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = data.aws_subnet.selected.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = file("user_data.sh")

  tags = {
    Name = "Terraform-EC2-Docker"
  }
}
```
- 🧾 outputs.tf
```bash
# outputs.tf
output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.web_instance.id
}

output "public_ip" {
  description = "EC2 Public IP Address"
  value       = aws_instance.web_instance.public_ip
}
```
### 4️⃣ Initialize and Validate Terraform
```bash
terraform init
terraform fmt
terraform validate
```
 - ✅ Output: Success! The configuration is valid.

### 5️⃣ Apply Terraform Configuration
```bash
terraform plan
terraform apply -auto-approve
```
- ✅ Result: EC2 instance created and Docker installed automatically.

### 6️⃣ Verify Docker on EC2
```bash
ssh -i "your-key.pem" ubuntu@<public_ip>
docker --version
cat /home/ubuntu/docker_status.txt
```
- ✅ Expected Output:
```bash
Docker installed successfully!
```
## 📸 Proof of Work (NulClass Submission)

| Step | Description |
|------|--------------|
| ✅ **Terraform Apply** | EC2 created successfully |
| 🐳 **Docker Verification** | Docker installed via `user_data` |
| 🌐 **GitHub Repo** | Pushed clean final project files |

#### 🧠 **Key Learnings**
- Writing Terraform IaC scripts from scratch

- Handling AWS region & AMI compatibility

- Secure AWS CLI credential management

- Automating Docker setup using user_data

- Cleaning large files & Git history for a professional repo

### 🏁 **Conclusion**
**This project demonstrates my ability to:**
- Build and automate cloud infrastructure using Terraform + AWS\
- Implement IaC best practices and security measures\
- Handle real-world DevOps issues end-to-end\
✅ Successfully delivered as **NulClass Internship** Task 02

## 🙏 Acknowledgment
Special thanks to NulClass for assigning this hands-on DevOps automation project.\
It provided real-world experience with Terraform, AWS EC2, Docker, and infrastructure automation.

#### Author: ✨ Aman Raj Raw
📧 amanrajraw0gmail.com\
🌐 GitHub: Amanrajraw0


