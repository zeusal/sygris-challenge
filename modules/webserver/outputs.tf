output "sg_tf_web" {
  value = "${aws_security_group.web-sg.id}"
}

output "tf_web_dns" {
  value = "${aws_lb.web-alb.dns_name}"
}