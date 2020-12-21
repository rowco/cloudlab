
# output "lb-dns" {
#     description = "DNS name of the local LB"
#     value = aws_lb.app-lb.dns_name
# }

output "back-dns" {
  description = "DNS name of BACK-1"
  value       = aws_instance.backend.*.private_dns
}

output "app-dns" {
  description = "DNS name of APP-1"
  value       = aws_instance.app.*.private_dns
}

output "nat-dns" {
  description = "DNS name of NAT host"
  value       = aws_instance.nat.*.public_dns
}

# output "admin-dns" {
#     description = "DNS name of Admin host"
#     value       = aws_instance.admin.public_dns
# }


