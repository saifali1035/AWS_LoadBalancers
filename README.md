# AWS_LoadBalancers
AWS Load Balancers

Link to access LBs - https://ap-south-1.console.aws.amazon.com/ec2/home?region=ap-south-1#LoadBalancers:

<img width="1500" alt="image" src="https://github.com/saifali1035/AWS_LoadBalancers/assets/37189361/1d24147e-18f1-4d45-9ae2-8e186f33770c">

As the name states LBs are used to balance the load or traffic between the target groups that you define for the LBs.

Below the 3 LBs available in AWS to use (Classic LB can be created but is not suggested by AWS) .

<img width="1500" alt="image" src="https://github.com/saifali1035/AWS_LoadBalancers/assets/37189361/7ef95fc0-5e3e-4178-979c-74edf903778a">

# 1. Application Load Balancer (HTTP / HTTPS)

Steps to create.
Under **Basic configuration**
1. Give your LB a name under **Load balancer name**.
2. Under **Scheme** set it as **Internet-facing**

```HCL
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
```

Under **Network mapping**
1. Under **VPC** select your VPC if you have one or AWS Default VPC will be selected.
2. In **Mappings** select the pulic AZs.
   
```HCL
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
```

Under **Security groups**
1. Create inbound and outbound rules

   *In our case we will create an App that will be running on port 8000 so we will create inbound rule to allow traffic from anywhere on port 80 and outbound we will allow outbound traffic to the set instance security groups*

```HCL
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
```

*and For EC2 instances , inbound rule will be custom TCP for 8000 and 22 from anywhere and outbound will be to anywhere*

```HCL
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
```

Under **Listeners and routing**
1. Set the Protocol and Port - *In our case it will be HTTP and 80* (As our LB will be listening on port 80 for requests)
   
```HCL
   resource "aws_lb_listener" "Web-Server-listener" {
  load_balancer_arn = aws_lb.Web-server-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Web-server-TG.arn
  }
}
```
3. In this stage we will be asked to select or create a taget group where our requests will be routed.
We will create 2 seprate taget groups for path based routing.
```HCL
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

```
   
   2.1 Lets create , Under **Basic configuration** select Instances.
   
   2.2 Set a **Target group name** and set the port.

   2.3 Create **Listener Rules**

```HCL
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
```
   
   2.4 Click on create and you will be redirected to a page where you need to register the instances.
   
   2.5 Create EC2 instances if not already created with below user data and register them as targets.
```HCL
resource "aws_instance" "Web-server" {
  count = 2
  ami = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.instance-security-group.name]
  user_data = file("${path.module}/script.sh")
  associate_public_ip_address = "false"
  tags = {
    Name = "Web-Server"
  }
}

resource "aws_instance" "Web-server-2" {
  count = 2
  ami = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.instance-security-group.name]
  user_data = file("${path.module}/second_script.sh")
  associate_public_ip_address = "false"
  tags = {
    Name = "Web-Server-2"
  }
}



```
    2.5.1 Ec2 uses below 2 scripts.
    
```bash
script.sh
#!/usr/bin/env bash
IP=$(curl -s ifconfig.me)
echo "Hi this is a web page and this reply is coming from $IP" > /home/ubuntu/index.html
python3 -m http.server 8000 --directory /home/ubuntu/ &
```

```bash
second_script.sh
#!/usr/bin/env bash
IP=$(curl -s ifconfig.me)
echo "Hi this is the second page and this reply is coming from $IP" > /home/ubuntu/second.html
python3 -m http.server 8000 --directory /home/ubuntu/ &
```   

