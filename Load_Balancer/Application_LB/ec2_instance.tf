resource "aws_instance" "Web-server" {
  count = 2
  ami = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.instance-security-group.name]
  user_data = file("${path.module}/script.sh")
  tags = {
    Name = "Web-Server"
  }
}

