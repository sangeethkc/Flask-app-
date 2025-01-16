output "ec2_instance_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.jiitak_distribution.id
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.jiitak_distribution.domain_name
}

output "app_url" {
  value = "https://${var.domain_name}"
}
