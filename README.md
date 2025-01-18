# Deploy Flask Application to EC2 with Docker and Terraform

This repository contains the code for a Flask application and its automated deployment using Docker, Terraform, and GitHub Actions. The application serves as a basic web service running on AWS infrastructure.



## Features

- **Flask Web Application**: A simple Python Flask app to serve web content.
- **Dockerization**: The app is containerized using Docker for easy deployment.
- **CI/CD Pipeline**: Automated build and deployment pipeline using GitHub Actions.
- **AWS Infrastructure**: EC2 instance provisioning, CloudFront setup, and Route 53 DNS configuration using Terraform.

## Prerequisites

- Docker installed locally.
- AWS account with necessary IAM permissions.
- Terraform installed locally.
- Python 3.9 or higher for local testing.
- GitHub repository with the following secrets:
  - `DOCKER_USERNAME`: Docker Hub username.
  - `DOCKER_ACCESS_TOKEN`: Docker Hub access token.
  - `EC2_PUBLIC_IP`: Public IP of the EC2 instance.
  - `EC2_PRIVATE_KEY`: Private key for accessing the EC2 instance.
  - `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`: AWS credentials for Terraform.

## Terraform
 
> SSH is not enabled via terraform on purpose. So you have to do it by editing Inbound rules in security groups in AWS or add the configuration under ```resource "aws_security_group" "web_sg"``` in `main.tf` file


```
  # SSH Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow all IPs
  }
```

## Secrets files for Terraform (secrets.tfvars)

```
  ami_id         = "ami-0e1bed4f06a3b463d" // This can be obtained from AMI Catalogue from AWS
  instance_type  = "t2.micro"
  domain_name    = "site.example.com" // if you have a domain and is added to R53 add it here.
  hosted_zone    = "example.com" 
  account_id     = "123456789012" // your AWS Account ID
  cert_id        = "i6l8whar-6rerq2beg-799uj-qxl4jca-1bp" // Certificate for my domain fo HTTPS 
  ssh_key        = <<SSH Public Key>> // or you can copy the public key from your system to the EC2
```

## Deployment Process

### 1. Build and Push Docker Image

The CI/CD pipeline in `GitHub Actions` automates the build and push process:
- Builds the Docker image from the `Dockerfile`.
- Pushes the image to Docker Hub.

### 2. EC2 Instance Setup

Terraform provisions the EC2 instance and its security group:
- The Flask app runs inside a Docker container on the EC2 instance.
- Security groups allow HTTP and HTTPS access.

### 3. CloudFront and Route 53

Terraform configures:
- **CloudFront**: For content distribution.
- **Route 53**: For DNS configuration pointing to the CloudFront distribution.

### 4. Automated Deployment

The `deploy-container` job in GitHub Actions:
- Pulls the latest Docker image to the EC2 instance.
- Restarts the container with the updated image.

## Repository Structure
```plaintext
├── app/
│   ├── run.py              # Flask application code
│   └── requirements.txt    # Python dependencies
│   └── Dockerfile          # Containerization
├── terraform/
│   ├── main.tf             # Terraform configuration
│   └── outputs.tf          # Terraform outputs
│   ├── variables.tf        # Input variables for Terraform
│   └── secrets.tfvars      # Terraform secrets
├── .github/
│   └── workflows/
│       └── flask.yml       # GitHub Actions workflow
├── Dockerfile              # Docker configuration for the Flask app
└── README.md               # Project documentation
└── .gitignore              # Git ignore
```

## Usage

1. Commit and push changes to the `main` branch.
2. GitHub Actions will trigger the pipeline, deploying the updated application.

## Acknowledgments

- Flask: Python microframework for web development.
- Docker: For containerization.
- Terraform: Infrastructure as Code.
- AWS: Cloud platform for deployment.

