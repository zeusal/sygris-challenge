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

variable "public_subnet_id" {
  type = string
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