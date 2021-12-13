output "jumphost_dns" {
  value = "${aws_instance.jumphost.private_dns}"
}