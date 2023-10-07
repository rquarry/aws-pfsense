output "region" {
  value = var.region
}

output "pfsense_public_ip" {
  value = aws_instance.pfsense.public_ip
}