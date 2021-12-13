provider "aws" {
  alias      = "management"
  access_key = var.management_access_key
  secret_key = var.management_secret_key
  region     = "${var.region}"
  default_tags {
    tags = {
      Environment = "Management"
      Project     = "Sygris"
    }
  }
}

provider "aws" {
  access_key = var.operational_access_key
  secret_key = var.operational_secret_key
  region     = "${var.region}"
  default_tags {
    tags = {
      Environment = "Operational"
      Project     = "Sygris"
    }
  }
}