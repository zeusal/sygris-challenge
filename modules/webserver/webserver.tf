resource "aws_key_pair" "webserver" {
  key_name   = "deployer-key"
  public_key = "${var.pub_key}"
}

resource "aws_iam_instance_profile" "webserver" {
  name = "web-profile"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = "web-role"
  path = "/"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
})

  tags = {
    Name = "web-role"
  }
}

resource "aws_launch_configuration" "lc-web" {
  instance_type        = "${var.instance_type}"
  image_id             = "${var.ami_id}"
  security_groups      = ["${aws_security_group.web-sg.id}", "${var.default_sg}", "${var.internet_sg}", "${var.ssh_sg}"]
  key_name             =  aws_key_pair.webserver.id
  user_data            = templatefile("${path.module}/bastion.tftpl", { priv_key = var.priv_key, pub_key = var.pub_key, ssh_user = var.ssh_user })
  iam_instance_profile = aws_iam_instance_profile.webserver.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg-web" {
  name                 = "asg-web"
  launch_configuration = "${aws_launch_configuration.lc-web.name}"
  min_size             = "${var.asg_min}"
  max_size             = "${var.asg_max}"
  desired_capacity     = "${var.asg_desired}"
  target_group_arns    = ["${aws_lb_target_group.tg-web.arn}"]
  vpc_zone_identifier  = "${var.private_subnets_ids}"

  lifecycle {
  create_before_destroy = true
  }

  tags = [
    {
      key                 = "Project"
      value               = "${var.project}"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "TF-Web"
      propagate_at_launch = true
    },
  ]
}

resource "aws_security_group" "alb-sg" {
  name        = "${var.project}-alb-SG"
  description = "Security Group for Web Server"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "443"
    to_port = "443"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-alb-SG"
  }
}

resource "aws_security_group" "web-sg" {
  depends_on  = [aws_security_group.alb-sg]
  name        = "${var.project}-web-SG"
  description = "Security Group for Web Server"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port        = "8888"
    to_port          = "8888"
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb-sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups  = [aws_security_group.alb-sg.id]
  }

  tags = {
    Name = "${var.project}-web-SG"
  }
}

resource "aws_lb_target_group" "tg-web" {
  name     = "tg-web-8888"
  port     = 8888
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path                = "/index.html"
    port                = 8888
    healthy_threshold   = 10
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 10
    matcher             = "200"
  }
}

resource "aws_lb" "web-alb" {
  name            = "${var.project}-web-alb"
  internal        = false
  security_groups = ["${aws_security_group.alb-sg.id}"]
  subnets         = "${var.public_subnets_ids}"

  tags = {
    Name = "${var.project}-web-alb"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.web-alb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
  target_group_arn = "${aws_lb_target_group.tg-web.arn}"
  type             = "forward"
  }
}

resource "aws_acm_certificate" "custom-cert" {
  private_key = base64decode("${var.hosted_zone_key}")
  certificate_body = base64decode("${var.hosted_zone_cert}")
}

resource "aws_lb_listener" "front_end_443" {
  depends_on  = [aws_acm_certificate.custom-cert]
  load_balancer_arn = "${aws_lb.web-alb.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.custom-cert.arn

  default_action {
  target_group_arn = "${aws_lb_target_group.tg-web.arn}"
  type             = "forward"
  }
}

resource "aws_route53_record" "www" {
  zone_id = "${var.hosted_zone_id}"
  name    = "${var.hosted_zone}"
  type    = "A"

  alias {
    name                   = aws_lb.web-alb.dns_name
    zone_id                = aws_lb.web-alb.zone_id
    evaluate_target_health = true
  }
}