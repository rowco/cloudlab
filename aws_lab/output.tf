output "app-1-dns" {
  description = "DNS name of APP-1"
  value       = aws_instance.app-1.public_dns
}