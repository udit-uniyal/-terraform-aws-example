Step 1: Setting Up the GitHub Repository:*

1. Create a new repository on GitHub named terraform-aws-example.
2. Clone the repository to your local machine using the following command:

    bash
    git clone https://github.com/udit-uniyal/terraform-aws-example.git
    cd terraform-aws-example
    

*Step 2: Writing Terraform Scripts:*

Create a Terraform script (main.tf) to provision an AWS EC2 instance with a security group allowing all inbound traffic. This script will serve as our example of a vulnerable configuration.

hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


*Step 3: Setting Up GitHub Actions:*

Create a GitHub Actions workflow to define the CI/CD pipeline. We'll name it .github/workflows/main.yml.

yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v2

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v1
        with:
          terraform_version: 1.0.0

      - name: Terraform Init
        run: terraform init
      - name: Checkov Scan
        run: checkov -d . --quiet --framework terraform


*Step 4: Integrating Checkov for Security Scanning:*

Ensure Checkov is installed in your CI/CD environment. The GitHub Actions workflow defined earlier will automatically install Checkov using Docker.

*Step 5: Pushing Changes and Running the Pipeline:*

Commit and push your changes to the GitHub repository:

bash
git add .
git commit -m "Added Terraform scripts"
git push origin main


GitHub Actions will automatically trigger the CI/CD pipeline defined in the main.yml workflow file.

*Step 6: Reviewing Checkov Results:*

Once the pipeline executes, review the Checkov scan results in the GitHub Actions logs. Checkov will report the insecure configuration of allowing all inbound traffic (0.0.0.0/0) in the security group.

*Step 7: Addressing Issues:*

Update the main.tf file to restrict inbound traffic to specific ports and/or IP ranges according to your security requirements.

hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

resource "aws_security_group" "allow_specific" {
  name        = "allow_specific"
  description = "Allow specific inbound traffic"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["your-ip-address/32"]
  }
}


*Step 8: Deployment:*

Commit and push your changes again to trigger the pipeline. Once the Checkov scan passes without critical issues, the pipeline will proceed to deploy the updated infrastructure.

By following these steps and addressing the issues detected by Checkov, you've improved the security of your Terraform scripts and ensured compliance with your organization's policies.
