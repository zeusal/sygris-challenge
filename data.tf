data "aws_caller_identity" "management" {
  provider = aws.management
}

data "aws_caller_identity" "operational" {
}

data "aws_route53_zone" "hosted_zone_id" {
  name = "${var.hosted_zone}"
}