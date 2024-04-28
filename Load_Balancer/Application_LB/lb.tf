resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Default subnet for us-west-2a"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "ap-south-1c"

  tags = {
    Name = "Default subnet for us-west-2a"
  }
}

resource "aws_lb" "Web-server-lb" {
    name = "Web-server-lb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.load-balancer-security-group.id] 
    subnets = [ aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id ]
    }

resource "aws_lb_target_group" "Web-server-TG" {
  name     = "tf-web-server-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
}

resource "aws_lb_target_group_attachment" "Web-server-TG-attachment" {
  for_each = {
    for k, v in aws_instance.Web-server :
    k => v
  }
  target_group_arn = aws_lb_target_group.Web-server-TG.arn
  target_id        = each.value.id
  port             = 8000
}

resource "aws_lb_listener" "Web-Server-listener" {
  load_balancer_arn = aws_lb.Web-server-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Web-server-TG.arn
  }
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.Web-server-lb.dns_name
}

