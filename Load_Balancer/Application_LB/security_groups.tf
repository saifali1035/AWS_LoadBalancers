resource "aws_security_group" "instance-security-group" {
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress  {
      from_port        = 8000
      to_port          = 8000
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }

}

resource "aws_security_group" "load-balancer-security-group" {
    egress {
    from_port        = 8000
    to_port          = 8000
    protocol         = "tcp"
    security_groups = [ aws_security_group.instance-security-group.id ]
  }

   egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [ aws_security_group.instance-security-group.id ]
  }
      ingress {
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      }

}