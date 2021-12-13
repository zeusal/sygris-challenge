variable "project" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "pub_key" {
  type = string
}

variable "priv_key" {
  type = string
}

variable "ssh_user" {
  type = string
}

variable "private_subnets_ids" {
  type = list(string)
}

variable "public_subnets_ids" {
  type = list(string)
}

variable "default_sg" {
  type = string
}

variable "internet_sg" {
  type = string
}

variable "ssh_sg" {
  type = string
}

variable "asg_min" {
  type = number
}

variable "asg_max" {
  type = number
}

variable "asg_desired" {
  type = number
}

variable "hosted_zone" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "hosted_zone_key" { 
  type        = string
}

variable "hosted_zone_cert" { 
  type        = string
}