
resource "aws_key_pair" "waqas" {
  key_name   = "waqas"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDC+/Lx4u+g0S2HIKpb3x/jtXhmSwOuI3TBf4wc+YRjMTsP/5EM5XnKcME7jFRZP25tWTWRzJYwgj6gyhfBzxkR1eVKojQWPMD2qRKqYaV6VtCOadgkzbo6t6gYLmjEcr+8qy2ncobDtYIm2Vu+9K34OiJ1XSOHRxQAyPUQDrS8kYi7gtn75QkIKXHBWolCIWZWUTp2dXXFJXqTHWWTXV9o/2K/UKyjmLmyHGxSRnBg9/VsH7IxqbZkKX10R0g5Hw1tgyhFMFfCrfSj0su9CnD6mF4jL5SDhL3FRVWwnerxON4LmAxMd2HM9p1WS/h+iaIR+j2i2Ja0giYIm/xiq2TP9jCIO225koXXvq2/r+FJAFpivgZJc/63Q7Iea76QwbABE9bHRJtcotTRnRBT6Dssd29Cte+weyi6ePEwNaeLtxASXTABMNMkTLAZVYeE9LpBWnUNGOMumoncb4n3y/3DMg4jFaZb4KedxlNLC270PFj4M8RNfCD8/Pg/PppURjk= sb@DESKTOP-68T5U4Q"
}

resource "aws_launch_configuration" "my-test-launch-config" {
  image_id        = "ami-04468e03c37242e1e"
  instance_type   = "t2.micro"
  key_name        = "waqas"
  security_groups = ["${aws_security_group.my-asg-sg.id}"]

  user_data = <<-EOF
              #!/bin/bash
              yum -y install httpd
              echo "Hello world" > /var/www/html/index.html
              service httpd start
              chkconfig httpd on
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.my-test-launch-config.name
  vpc_zone_identifier  = ["${var.subnet1}", "${var.subnet2}"]
  target_group_arns    = ["${var.target_group_arn}"]
  health_check_type    = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "my-test-asg"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "my-asg-sg" {
  name   = "my-asg-sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "inbound_ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.my-asg-sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.my-asg-sg.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.my-asg-sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
