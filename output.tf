


output "lb-dns" {
    description = "DNS name of the local LB"
    value = module.aws_lab.lb-dns
}

output "app-dns" {
    description = "DNS name of APP-1"
    value       = module.aws_lab.app-dns
}

output "admin-dns" {
    description = "DNS name of Admin host"
    value       = module.aws_lab.admin-dns
}


output "api-frisbee" {
    description = "Command to run to test nodes"
    value       = format("curl -X POST --header 'Content-Type: application/json' -d %s -kv %s",
     jsonencode({"targets":[ module.aws_lab.app-dns[0],module.aws_lab.app-dns[1],module.aws_lab.app-dns[2] ] }),
     module.aws_lab.lb-dns )
}

output "ssh-admin" {
    value       = format("ssh -i tf_key.pem ec2-user@%s",
    module.aws_lab.admin-dns )
}