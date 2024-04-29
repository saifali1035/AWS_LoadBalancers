data "aws_elb_service_account" "elb_account_id" {}

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
      access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    enabled = true
  }
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






resource "aws_lb_target_group" "Web-server-2-TG" {
  name     = "tf-web-server-2-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
}

resource "aws_lb_target_group_attachment" "Web-server-2-TG-attachment" {
  for_each = {
    for k, v in aws_instance.Web-server-2 :
    k => v
  }
  target_group_arn = aws_lb_target_group.Web-server-2-TG.arn
  target_id        = each.value.id
  port             = 8000
}

resource "aws_lb_listener_rule" "Web-server-2-rule" {
  listener_arn = aws_lb_listener.Web-Server-listener.arn
 priority     = 60

 action {
   type             = "forward"
   target_group_arn = aws_lb_target_group.Web-server-2-TG.arn
 }

 condition {
   path_pattern {
     values = ["/second*"]
   }
 }
}





