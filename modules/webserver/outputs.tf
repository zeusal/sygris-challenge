output "sg_tf_web" {
  value = "${aws_security_group.web_sg.id}"
}

output "tf_web_dns" {
  value = "${aws_lb.web_alb.dns_name}"
}