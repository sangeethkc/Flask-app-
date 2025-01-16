provider "aws" {
  region = "us-west-2"
  profile = "sangeeth_iam"
}

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

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.ssh_key
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = aws_key_pair.deployer.key_name

  tags = {
    Name = "jiitak-web-server"
  }

  

  security_groups = [aws_security_group.web_sg.name]

  associate_public_ip_address = true

}

resource "aws_security_group" "web_sg" {
  name        = "web-server-sg-new"
  description = "Allow HTTP and HTTPS access"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

data "aws_route53_zone" "hosted_zone" {
  name         = var.hosted_zone
  private_zone = false
}

data "aws_instance" "web_server" {
  depends_on = [aws_instance.web_server]

  filter {
    name   = "tag:Name"
    values = ["jiitak-web-server"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"] 
  }
}

resource "aws_cloudfront_distribution" "jiitak_distribution" {
  origin {
    domain_name = aws_instance.web_server.public_dns
    origin_id   = "EC2-${aws_instance.web_server.public_ip}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
      
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${var.domain_name}"
  default_root_object = ""
  aliases = [var.domain_name]

  default_cache_behavior {
    target_origin_id       = "EC2-${aws_instance.web_server.public_ip}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:${var.account_id}:certificate/${var.cert_id}"
    ssl_support_method        = "sni-only"
    minimum_protocol_version  = "TLSv1.2_2021"
    
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = var.tags
}

resource "aws_route53_record" "cloudfront_alias" {
  zone_id = data.aws_route53_zone.hosted_zone.id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.jiitak_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.jiitak_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
