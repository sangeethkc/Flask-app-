variable "domain_name" {
  description = "Custom domain name for CloudFront distribution"
  type        = string
  default     = "jiitak.sangeeth.cloud"
}

variable "hosted_zone" {
  description = "Route 53 hosted zone for domain"
  type        = string
  default     = "sangeeth.cloud"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "tags" {
  description = "Tags to assign to all resources"
  type        = map(string)
  default     = {
    "Environment" = "Production"
    "Project"     = "jiitak"
  }
}

variable "account_id" {
  description = "AWS Account ID"
  type = string
}

variable "cert_id" {
  description = "Certificate ID"
  type = string
}

variable "ssh_key" {
  type = string
}

# variable "ec2_instance_ip" {
#   description = "Public IP address of the EC2 instance"
#   type        = string
# }
