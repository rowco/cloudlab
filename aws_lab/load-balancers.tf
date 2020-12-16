resource "aws_lb" "app-lb" {
    name = "app-lb"
    load_balancer_type = "network"
    subnets = aws_subnet.az.*.id
    internal = "true"
}

resource "aws_lb_listener" "app-ls" {
    load_balancer_arn = aws_lb.app-lb.arn
    port                = 80
    protocol            = "TCP"
    default_action {
        target_group_arn = aws_lb_target_group.app-tg.arn
        type             = "forward"
    }
}

resource "aws_lb_target_group" "app-tg" {
    name     = "app-tg"
    port     = 80
    protocol = "TCP"
    vpc_id   = aws_vpc.az_vpc.id
    #load_balancing_algorithm_type = "round_robin"
    target_type = "instance"
    health_check {
        interval = 10
        port = 80
        protocol = "HTTP"
        path = "/"
        healthy_threshold = 3
        unhealthy_threshold = 3
    }
}

resource "aws_lb_target_group_attachment" "app-tg-att" {
    count = 3
    target_group_arn = aws_lb_target_group.app-tg.arn
    target_id        = aws_instance.app[count.index].id
    port             = 80
}