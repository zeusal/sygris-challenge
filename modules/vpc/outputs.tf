output "vpc_id" {
  description = "ID of the VPC"
  value       = "${aws_vpc.main.id}"
}

output "vpc_arn" {
  value = "${aws_vpc.main.arn}"
}

output "default_sg" {
  value = "${aws_security_group.default.id}"
}

output "internet_sg" {
  value = "${aws_security_group.internet.id}"
}

output "ssh_sg" {
  value = "${aws_security_group.ssh.id}"
}

output "private_subnets_ids" {
  value = "${aws_subnet.private.*.id}"
}

output "public_subnets_ids" {
  value = "${aws_subnet.public.*.id}"
}

output "private_route_id" {
  value = "${aws_route_table.private.id}"
}

output "public_route_id" {
  value = "${aws_route_table.public.id}"
}