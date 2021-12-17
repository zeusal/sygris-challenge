## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (~> 3.69.0)

## Run

To try any example, clone this repository, set the following parameters into input.tfvars:

- management_access_key  = ""
- management_secret_key  = ""
- operational_access_key = ""
- operational_secret_key = ""
- priv_key = ""
- pub_key = ""
- hosted_zone_cert = ""
- hosted_zone_key = ""

Or run the following commands for generate input.tfvars file:

```shell
$ ./setup.sh filename-for-key operational-access-key operational-secret-key management-access-key management-secret-key
```

And run the following command from within the example's directory:

### Deploy

```shell
$ terraform init; terraform apply -auto-approve -var-file="input.tfvars"
```

### Destroy

```shell
$ terraform destroy -auto-approve -var-file="input.tfvars"
```


## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (3.69.0)

- <a name="provider_aws.management"></a> [aws.management](#provider\_aws.management) (3.69.0)

## Modules

The following Modules are called:

### <a name="module_jumphost"></a> [jumphost](#module\_jumphost)

Source: ./modules/jumphost

Version:

### <a name="module_vpc"></a> [vpc](#module\_vpc)

Source: ./modules/vpc

Version:

### <a name="module_webserver"></a> [webserver](#module\_webserver)

Source: ./modules/webserver

Version:

## Resources

The following resources are used by this module:

- [aws_route.management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
- [aws_route.management_pub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
- [aws_route.operational](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
- [aws_vpc_peering_connection.management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) (resource)
- [aws_vpc_peering_connection_accepter.operational](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) (resource)
- [aws_caller_identity.management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
- [aws_caller_identity.operational](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
- [aws_route53_zone.hosted_zone_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_hosted_zone_cert"></a> [hosted\_zone\_cert](#input\_hosted\_zone\_cert)

Description: Cert for hostedzone

Type: `string`

### <a name="input_hosted_zone_key"></a> [hosted\_zone\_key](#input\_hosted\_zone\_key)

Description: Key of hostedzone certificate

Type: `string`

### <a name="input_management_access_key"></a> [management\_access\_key](#input\_management\_access\_key)

Description: Access Key of management AWS Account

Type: `string`

### <a name="input_management_secret_key"></a> [management\_secret\_key](#input\_management\_secret\_key)

Description: Secret Key of management AWS Account

Type: `string`

### <a name="input_operational_access_key"></a> [operational\_access\_key](#input\_operational\_access\_key)

Description: Access Key of operational AWS Account

Type: `string`

### <a name="input_operational_secret_key"></a> [operational\_secret\_key](#input\_operational\_secret\_key)

Description: Secret Key of operational AWS Account

Type: `string`

### <a name="input_priv_key"></a> [priv\_key](#input\_priv\_key)

Description: SSH Private Key for EC2 Instances

Type: `string`

### <a name="input_pub_key"></a> [pub\_key](#input\_pub\_key)

Description: SSH Public Key for EC2 Instances

Type: `string`


### <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id)

Description: n/a

Type: `string`

Default: `"ami-04dd4500af104442f"`

### <a name="input_asg_desired"></a> [asg\_desired](#input\_asg\_desired)

Description: Actual number of instances to be used by the ASG.

Type: `number`

Default: `2`

### <a name="input_asg_max"></a> [asg\_max](#input\_asg\_max)

Description: Maximum number of instances to be used by the ASG.

Type: `number`

Default: `10`

### <a name="input_asg_min"></a> [asg\_min](#input\_asg\_min)

Description: Minimum number of instances to be used by the ASG.

Type: `number`

Default: `2`

### <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones)

Description: A list of availability zones in which to create subnets

Type: `list(string)`

Default:

```json
[
  "eu-west-1a",
  "eu-west-1b",
  "eu-west-1c"
]
```

### <a name="input_cidrs"></a> [cidrs](#input\_cidrs)

Description: n/a

Type: `map(any)`

Default:

```json
{
  "management": "100.80.0.0/16",
  "operational": "120.80.0.0/16"
}
```

### <a name="input_hosted_zone"></a> [hosted\_zone](#input\_hosted\_zone)

Description: n/a

Type: `string`

Default: `"256490151058.sygris.net"`

### <a name="input_jumphost_type"></a> [jumphost\_type](#input\_jumphost\_type)

Description: Jump host instance type

Type: `string`

Default: `"t3.micro"`

### <a name="input_management_priv_sub_cidrs"></a> [management\_priv\_sub\_cidrs](#input\_management\_priv\_sub\_cidrs)

Description: n/a

Type: `list(string)`

Default:

```json
[
  "100.80.3.0/24",
  "100.80.4.0/24",
  "100.80.5.0/24"
]
```

### <a name="input_management_pub_sub_cidrs"></a> [management\_pub\_sub\_cidrs](#input\_management\_pub\_sub\_cidrs)

Description: n/a

Type: `list(string)`

Default:

```json
[
  "100.80.0.0/24",
  "100.80.1.0/24",
  "100.80.2.0/24"
]
```

### <a name="input_operational_priv_sub_cidrs"></a> [operational\_priv\_sub\_cidrs](#input\_operational\_priv\_sub\_cidrs)

Description: n/a

Type: `list(string)`

Default:

```json
[
  "120.80.3.0/24",
  "120.80.4.0/24",
  "120.80.5.0/24"
]
```

### <a name="input_operational_pub_sub_cidrs"></a> [operational\_pub\_sub\_cidrs](#input\_operational\_pub\_sub\_cidrs)

Description: n/a

Type: `list(string)`

Default:

```json
[
  "120.80.0.0/24",
  "120.80.1.0/24",
  "120.80.2.0/24"
]
```

### <a name="input_project"></a> [project](#input\_project)

Description: n/a

Type: `string`

Default: `"Sygris"`

### <a name="input_region"></a> [region](#input\_region)

Description: n/a

Type: `string`

Default: `"eu-west-1"`

### <a name="input_ssh_user"></a> [ssh\_user](#input\_ssh\_user)

Description: Default EC2 SSH User

Type: `string`

Default: `"ec2-user"`

### <a name="input_webserver_type"></a> [webserver\_type](#input\_webserver\_type)

Description: Web server instance type

Type: `string`

Default: `"t3.micro"`

## Outputs

No outputs.
