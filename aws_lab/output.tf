output "app-1-dns" {
  description = "DNS name of APP-1"
  value       = aws_instance.app.*.public_dns
}


