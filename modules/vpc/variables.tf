variable "project" {
  type    = string
}

variable "scope" {
  type = string
}

variable "enable_dns_hostnames" {
  type    = bool
  default = "true"
}
variable "enable_dns_support" {
  type    = bool
  default = "true"
}

variable "base_cidr_block" {
  description = "A /24 CIDR range definition."
  type        = string
}

variable "availability_zones" {
  description = "A list of availability zones in which to create subnets"
  type        = list(string)
}

variable "public_subnets_cidr" {
  type = list(string)
}

variable "private_subnets_cidr" {
  type = list(string)
}