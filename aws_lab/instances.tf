
# Application instances
resource "aws_instance" "app" {

    count = 3

    ami = data.aws_ami.aws-linux.id
    instance_type = "t2.micro"
    subnet_id = "aws_subnet.az_${ count.index + 1}.id"
    vpc_security_group_ids = [aws_security_group.sg-app-default.id]
    key_name = "tf_key"
    tags = {
        Name = "App ${count.index}"
    }
    user_data = file("./cloud-init/docker-api-frisbee")
}

# # Backend instances
# resource "aws_instance" "backend-1" {

#     ami = data.aws_ami.aws-linux.id
#     instance_type = "t2.micro"
#     subnet_id = aws_subnet.bz_1.id
#     vpc_security_group_ids = [aws_security_group.sg-backend-default.id]

#     key_name = "tf_key"

#     tags = {
#         Name = "Backend 1"
#     }
#     user_data = file("./cloud-init/python-api-frisbee")


# }