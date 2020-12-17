output "ssh-key" {
  value = tls_private_key.deployer.private_key_pem
}

output "back-dns" {
    description = "DNS name of BACK-1"
    value       = module.aws_lab.back-dns
}

output "app-dns" {
    description = "DNS name of APP-1"
    value       = module.aws_lab.app-dns
}

output "nat-dns" {
    description = "DNS name of NAT host"
    value       = module.aws_lab.nat-dns
}

