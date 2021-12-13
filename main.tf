module "vpc_management" {
  source               = "./modules/vpc"
  base_cidr_block      = var.cidrs["management"]
  public_subnets_cidr  = "${var.management_pub_sub_cidrs}"
  private_subnets_cidr = "${var.management_priv_sub_cidrs}"
  availability_zones   = "${var.availability_zones}"
  scope                = "management"
  project              = "${var.project}"
  providers = {
    aws = aws.management
  }
}

module "vpc_operational" {
  source               = "./modules/vpc"
  base_cidr_block      = var.cidrs["operational"]
  public_subnets_cidr  = "${var.operational_pub_sub_cidrs}"
  private_subnets_cidr = "${var.operational_priv_sub_cidrs}"
  availability_zones   = "${var.availability_zones}"
  scope                = "operational"
  project              = "${var.project}"
  providers = {
    aws = aws
  }
}

resource "aws_vpc_peering_connection" "management" {
  depends_on    = [module.vpc_management.vpc_id]
  provider      = aws.management
  vpc_id        = "${module.vpc_management.vpc_id}"
  peer_vpc_id   = "${module.vpc_operational.vpc_id}"
  peer_owner_id = data.aws_caller_identity.operational.account_id
  peer_region   = "${var.region}"
  auto_accept   = false
  tags = {
    Side = "Requester"
    Name = "${var.project}-peering"
  }
}

resource "aws_vpc_peering_connection_accepter" "operational" {
  depends_on    = [aws_vpc_peering_connection.management]
  vpc_peering_connection_id = aws_vpc_peering_connection.management.id
  auto_accept               = true
  tags = {
    Side = "Accepter"
    Name = "${var.project}-peering"
  }
}

resource "aws_route" "management" {
  depends_on                = [aws_vpc_peering_connection_accepter.operational]
  provider                  = aws.management
  route_table_id            = "${module.vpc_management.private_route_id}"
  destination_cidr_block    = var.cidrs["operational"]
  vpc_peering_connection_id = aws_vpc_peering_connection.management.id
}

resource "aws_route" "management_pub" {
  depends_on                = [aws_vpc_peering_connection_accepter.operational]
  provider                  = aws.management
  route_table_id            = "${module.vpc_management.public_route_id}"
  destination_cidr_block    = var.cidrs["operational"]
  vpc_peering_connection_id = aws_vpc_peering_connection.management.id
}

resource "aws_route" "operational" {
  depends_on                = [aws_vpc_peering_connection_accepter.operational]
  route_table_id            = "${module.vpc_operational.private_route_id}"
  destination_cidr_block    = var.cidrs["management"]
  vpc_peering_connection_id = aws_vpc_peering_connection.management.id
}

module "jumphost" {
  depends_on          = [module.vpc_management.vpc_id]
  source              = "./modules/jumphost"
  vpc_id              = "${module.vpc_management.vpc_id}"
  ami_id              = "${var.ami_id}"
  instance_type       = "${var.jumphost_type}"
  public_subnet_id    = "${module.vpc_management.public_subnets_ids[0]}"
  default_sg          = "${module.vpc_management.default_sg}"
  internet_sg         = "${module.vpc_management.internet_sg}"
  ssh_sg              = "${module.vpc_management.ssh_sg}"
  pub_key             = "${var.pub_key}"
  priv_key            = "${var.priv_key}"
  ssh_user            = "${var.ssh_user}"
  project             = "${var.project}"
  providers = {
    aws.management = aws.management
  }
}

module "webserver" {
  depends_on          = [module.vpc_operational.vpc_id]
  source              = "./modules/webserver"
  vpc_id              = "${module.vpc_operational.vpc_id}"
  ami_id              = "${var.ami_id}"
  instance_type       = "${var.webserver_type}"
  private_subnets_ids = "${module.vpc_operational.private_subnets_ids}"
  public_subnets_ids  = "${module.vpc_operational.public_subnets_ids}"
  default_sg          = "${module.vpc_operational.default_sg}"
  internet_sg         = "${module.vpc_operational.internet_sg}"
  ssh_sg              = "${module.vpc_operational.ssh_sg}"
  pub_key             = "${var.pub_key}"
  priv_key            = "${var.priv_key}"
  ssh_user            = "${var.ssh_user}"
  asg_max             = "${var.asg_max}"
  asg_min             = "${var.asg_min}"
  asg_desired         = "${var.asg_desired}"
  project             = "${var.project}"
  hosted_zone         = "${var.hosted_zone}"
  hosted_zone_id      = data.aws_route53_zone.hosted_zone_id.zone_id
  hosted_zone_key     = "${var.hosted_zone_key}"
  hosted_zone_cert    = "${var.hosted_zone_cert}"
}