
output "lb-dns" {
    description = "DNS name of the local LB"
    value = aws_lb.app-lb.dns_name
}

output "app-dns" {
    description = "DNS name of APP-1"
    value       = aws_instance.app.*.private_dns
}

output "admin-dns" {
    description = "DNS name of Admin host"
    value       = aws_instance.admin.public_dns
}


