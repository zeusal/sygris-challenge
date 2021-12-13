variable "project" {
  type    = string
  default = "Sygris"
}

variable "region" {
  type = string
  default = "eu-west-1"
}

variable "management_access_key" {
  description = "Access Key of management AWS Account"
  type        = string
  sensitive   = true
}
variable "management_secret_key" {
  description = "Secret Key of management AWS Account"
  type        = string
  sensitive   = true
}
variable "operational_access_key" {
  description = "Access Key of operational AWS Account"
  type        = string
  sensitive   = true
}
variable "operational_secret_key" {
  description = "Secret Key of operational AWS Account"
  type        = string
  sensitive   = true
}

variable "cidrs" {
  type = map(any)
  default = {
    operational = "120.80.0.0/16"
    management  = "100.80.0.0/16"
  }
}

variable "availability_zones" {
  description = "A list of availability zones in which to create subnets"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "operational_pub_sub_cidrs" {
  type    = list(string)
  default = ["120.80.0.0/24", "120.80.1.0/24", "120.80.2.0/24"]
}

variable "operational_priv_sub_cidrs" {
  type    = list(string)
  default = ["120.80.3.0/24", "120.80.4.0/24", "120.80.5.0/24"]
}

variable "management_pub_sub_cidrs" {
  type    = list(string)
  default =  ["100.80.0.0/24", "100.80.1.0/24", "100.80.2.0/24"]
}

variable "management_priv_sub_cidrs" {
  type    = list(string)
  default =  ["100.80.3.0/24", "100.80.4.0/24", "100.80.5.0/24"]
}

variable "webserver_type" {
  description = "Web server instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = ""
  type = string
  default = "ami-04dd4500af104442f"
}

variable "ssh_user" {
  description = "Default EC2 SSH User"
  default     = "ec2-user"
}

variable "priv_key" { 
  description = "SSH Private Key for EC2 Instances"
  type        = string
  sensitive   = true
}

variable "pub_key" { 
  description = "SSH Public Key for EC2 Instances"
  type        = string
  sensitive   = true
}

locals {
  priv_key = base64decode(var.priv_key)
}

variable "jumphost_type" {
  description = "Jump host instance type"
  type        = string
  default     = "t3.micro"
}

variable "asg_min" {
  description = "Minimum number of instances to be used by the ASG."
  type        = number
  default     = 2
}

variable "asg_max" {
  description = "Maximum number of instances to be used by the ASG."
  type        = number
  default     = 10
}

variable "asg_desired" {
  description = "Actual number of instances to be used by the ASG."
  type        = number
  default     = 2
}

variable "hosted_zone" {
  type = string
  default = "256490151058.sygris.net"
}

variable "hosted_zone_key" { 
  description = "Key of hostedzone certificate"
  type        = string
  sensitive   = true
}

variable "hosted_zone_cert" { 
  description = "Cert for hostedzone"
  type        = string
  sensitive   = true
}