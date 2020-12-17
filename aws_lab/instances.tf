resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.public_key
}

# Application instances
resource "aws_instance" "app" {
    count = 3
    ami = data.aws_ami.aws-linux.id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.az[count.index].id
    vpc_security_group_ids = [aws_security_group.sg-app-default.id]
    key_name = "deployer-key"
    tags = {
        Name = "App ${count.index + 1}"
    }
    user_data = file("./cloud-init/docker-api-frisbee")
    depends_on = [ aws_instance.nat ]
}


# Backend instances
resource "aws_instance" "backend" {
    count = 3
    ami = data.aws_ami.aws-linux.id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.bz[count.index].id
    vpc_security_group_ids = [aws_security_group.sg-backend-default.id]
    key_name = "deployer-key"
    tags = {
        Name = "Backend ${count.index + 1}"
    }
    user_data = file("./cloud-init/docker-api-frisbee")
    depends_on = [ aws_instance.nat ]
}

# # Admin instances
# resource "aws_instance" "admin" {
#     ami = data.aws_ami.aws-linux.id
#     instance_type = "t2.micro"
#     subnet_id = aws_subnet.lz.id
#     vpc_security_group_ids = [aws_security_group.sg-landing-default.id]
#     key_name = "tf_key"
#     tags = {
#         Name = "Admin Node"
#     }
#     # Generate the ad-hoc cloud-init config
#     # https://github.com/int128/terraform-aws-nat-instance/blob/master/main.tf
#     user_data = base64encode(join("\n", [
#         "#cloud-config",
#         yamlencode({
#             write_files : concat([
#                 {
#                 content : file("./tf_key.pem"),
#                 path : "/tmp/tf_key.pem",
#                 permissions : "0400",
#                 },
#             ])
#         })
#     ]))
# }

# NAT instances
resource "aws_instance" "nat" {
    count = 2
    ami = data.aws_ami.aws-linux.id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.lz_pub[count.index].id
    vpc_security_group_ids = [aws_security_group.sg-landing-default.id]
    key_name = "deployer-key"
    tags = {
        Name = "NAT Node ${count.index + 1}"
    }
    source_dest_check = "false"
    user_data = base64encode(join("\n", [
        "#cloud-config",
        yamlencode({
            runcmd : concat([
                "sysctl -w net.ipv4.ip_forward=1",
                "/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE",
            ]),
            write_files : concat([
                {
                content : var.private_key_pem,
                path : "/tmp/tf_key.pem",
                permissions : "0400",
                },
            ])
        })
    ]))
}